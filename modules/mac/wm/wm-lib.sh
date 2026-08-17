# shellcheck shell=bash
#
# Shared library for the yabai implementation of modules/window-manager-spec.md.
#
# Model
# -----
# A *pane* (spec 3.3) is a macOS space labelled "wm.<workspace-key>.<rank>",
# e.g. "wm.q.1". Labels are used everywhere instead of mission-control indices,
# because indices shift whenever spaces are created or moved between displays.
#
# *rank* is the effective priority rank: attached displays sorted by their stored
# priority and then densely renumbered 1..R. Unplugging the stored-primary
# monitor therefore promotes the stored-secondary to rank 1, which is what makes
# "the primary pane" (C5, C7) and single-display degradation (C10) coherent
# without any special-casing.
#
# yabai's DISPLAY_SEL does not accept a UUID, so UUIDs are the stored identity
# (as spec 3.2 requires) and are resolved to arrangement indices at call time.

[ -n "${WM_LIB_LOADED:-}" ] && return 0
WM_LIB_LOADED=1

# Deliberately not `set -e`: several capabilities are built on yabai commands
# that are expected to fail (e.g. "focus east" at the edge of the outermost
# display), and those failures are the control flow, not errors.
set -uo pipefail

# Spec 3.1. Opaque, ordered only for iteration; never reassign between machines.
WM_WS_KEYS="q w e r t s d g y x c v 0 1 2 3 4 5"

# Spec C11 "Storage": mutable state, separate from the generated (Nix store,
# read-only) configuration.
WM_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/yabai-wm"
WM_PRIORITY_FILE="$WM_STATE_DIR/display-priority"
WM_STICKY_FILE="$WM_STATE_DIR/sticky-displays"
WM_ACTIVE_WS_FILE="$WM_STATE_DIR/active-workspace"
# Space labels are yabai's own in-memory metadata and are lost every time yabai
# restarts, so which space is which pane has to be remembered ourselves. macOS
# space UUIDs are stable across yabai restarts and reboots, so they are what the
# map is keyed on. See wm_relabel_panes.
WM_PANE_MAP_FILE="$WM_STATE_DIR/panes"

wm_log() { printf '%s\n' "$*" >&2; }

# ---------------------------------------------------------------------------
# state files
# ---------------------------------------------------------------------------

# Replace <file> with stdin, atomically, and only when the content differs.
# Leaving an unchanged file untouched is what makes the priority tool
# byte-identical on a no-op rerun (spec conformance item 29).
# Returns 0 if the file was rewritten, 1 if it was already up to date.
wm_write_state() {
  local f=$1 tmp
  mkdir -p "$(dirname "$f")"
  tmp=$(mktemp "$f.XXXXXX") || return 1
  cat >"$tmp"
  if [ -f "$f" ] && cmp -s "$tmp" "$f"; then
    rm -f "$tmp"
    return 1
  fi
  mv -f "$tmp" "$f"
}

wm_valid_ws() {
  local ws=$1 k
  for k in $WM_WS_KEYS; do
    [ "$k" = "$ws" ] && return 0
  done
  return 1
}

wm_active_ws() {
  local ws=""
  [ -f "$WM_ACTIVE_WS_FILE" ] && ws=$(tr -d '[:space:]' <"$WM_ACTIVE_WS_FILE")
  wm_valid_ws "$ws" || ws=q
  printf '%s\n' "$ws"
}

wm_set_active_ws() {
  printf '%s\n' "$1" | wm_write_state "$WM_ACTIVE_WS_FILE" >/dev/null
  return 0
}

# ---------------------------------------------------------------------------
# displays
# ---------------------------------------------------------------------------

wm_query_displays() { yabai -m query --displays 2>/dev/null; }

# Stored priority order, one display UUID per line; line N is priority rank N.
#
# Detached displays are kept, so priorities survive unplugging and replugging in
# a different order (item 30). Any attached display we have never seen is
# appended at the lowest unused rank and persisted, which is the whole of C11
# "Unknown displays" (item 31) -- no manual step is ever required.
wm_read_priority() {
  local stored="" merged u
  [ -f "$WM_PRIORITY_FILE" ] && stored=$(grep -v '^[[:space:]]*$' "$WM_PRIORITY_FILE")
  merged=$stored
  for u in $(wm_query_displays | jq -r '.[].uuid // empty'); do
    if ! printf '%s\n' "$merged" | grep -qxF -- "$u"; then
      if [ -n "$merged" ]; then merged="$merged
$u"; else merged=$u; fi
    fi
  done
  if [ "$merged" != "$stored" ] && [ -n "$merged" ]; then
    printf '%s\n' "$merged" | wm_write_state "$WM_PRIORITY_FILE" >/dev/null
  fi
  [ -n "$merged" ] && printf '%s\n' "$merged"
  return 0
}

# Attached displays in effective-rank order, as "<rank>\t<uuid>\t<arrangement index>".
wm_attached_ranked() {
  local prio dj rank=0 u idx
  prio=$(wm_read_priority)
  dj=$(wm_query_displays)
  [ -n "$prio" ] && [ -n "$dj" ] || return 0
  while IFS= read -r u; do
    [ -n "$u" ] || continue
    idx=$(printf '%s' "$dj" | jq -r --arg u "$u" '.[] | select(.uuid==$u) | .index')
    [ -n "$idx" ] || continue # stored but not currently attached
    rank=$((rank + 1))
    printf '%d\t%s\t%s\n' "$rank" "$u" "$idx"
  done <<<"$prio"
}

# R: how many displays are attached. Never less than 1 in practice.
wm_display_count() { wm_attached_ranked | grep -c . ; }

wm_focused_display_uuid() {
  yabai -m query --displays --display 2>/dev/null | jq -r '.uuid // empty'
}

wm_display_index_for_rank() {
  local want=$1 r u idx
  while IFS=$'\t' read -r r u idx; do
    [ "$r" = "$want" ] && { printf '%s\n' "$idx"; return 0; }
  done < <(wm_attached_ranked)
  return 1
}

# ---------------------------------------------------------------------------
# stickiness (C6)
# ---------------------------------------------------------------------------

# Sticky UUIDs, restricted to displays that are actually attached. Pruning here
# means a sticky display that gets unplugged stops counting immediately, without
# needing a cleanup pass.
wm_sticky_uuids() {
  local attached u
  [ -f "$WM_STICKY_FILE" ] || return 0
  attached=$(wm_query_displays | jq -r '.[].uuid // empty')
  while IFS= read -r u; do
    [ -n "$u" ] || continue
    printf '%s\n' "$attached" | grep -qxF -- "$u" && printf '%s\n' "$u"
  done <"$WM_STICKY_FILE"
  return 0
}

wm_is_sticky() {
  [ -n "$1" ] || return 1
  wm_sticky_uuids | grep -qxF -- "$1"
}

wm_set_sticky() {
  # stdin: the new sticky set, one UUID per line. Sorted for a stable file.
  sort -u | grep -v '^[[:space:]]*$' | wm_write_state "$WM_STICKY_FILE" >/dev/null
  return 0
}

# Attached displays that follow workspace switches, in effective-rank order.
wm_live_ranked() {
  local sticky r u idx
  sticky=$(wm_sticky_uuids)
  while IFS=$'\t' read -r r u idx; do
    printf '%s\n' "$sticky" | grep -qxF -- "$u" || printf '%d\t%s\t%s\n' "$r" "$u" "$idx"
  done < <(wm_attached_ranked)
}

# Uphold the C6 invariant: at no point may every attached display be sticky.
#
# The spec leaves the mechanism open and only requires that a live display
# always exists and that no error is produced. We release the highest-priority
# sticky display. Calling this from the display_added/display_removed signals as
# well as from the toggle is what makes the all-sticky state unreachable rather
# than merely refused, including when the only live display is unplugged
# (item 19).
wm_ensure_live() {
  local rows first_u
  [ -n "$(wm_live_ranked)" ] && return 0
  rows=$(wm_attached_ranked)
  [ -n "$rows" ] || return 0
  first_u=$(printf '%s\n' "$rows" | head -n 1 | cut -f2)
  wm_sticky_uuids | grep -vxF -- "$first_u" | wm_set_sticky
}

# ---------------------------------------------------------------------------
# panes
# ---------------------------------------------------------------------------

wm_pane_label() { printf 'wm.%s.%s\n' "$1" "$2"; }

# Record which macOS space is which pane, keyed on the space UUID.
#
# Rebuilt wholesale from the current state rather than maintained incrementally,
# so it self-heals: whatever the labels say now becomes the record.
wm_save_pane_map() {
  yabai -m query --spaces 2>/dev/null \
    | jq -r '.[] | select(.label | test("^wm\\.[^.]+\\.[0-9]+$")) | "\(.uuid)\t\(.label)"' \
    | sort | wm_write_state "$WM_PANE_MAP_FILE" >/dev/null
  return 0
}

# Re-apply pane labels that yabai forgot.
#
# yabai keeps space labels in memory only, so every yabai restart wipes them and
# with them the entire pane model. Without this, restarting yabai (or rebooting)
# would silently scramble which workspace a window belongs to. Must run before
# anything that addresses a pane by label.
wm_relabel_panes() {
  local spaces uuid label row index cur
  [ -f "$WM_PANE_MAP_FILE" ] || return 0
  spaces=$(yabai -m query --spaces 2>/dev/null) || return 0
  while IFS=$'\t' read -r uuid label; do
    [ -n "$uuid" ] && [ -n "$label" ] || continue
    row=$(printf '%s' "$spaces" | jq -r --arg u "$uuid" \
      '.[] | select(.uuid == $u) | "\(.index)\t\(.label // "")"')
    [ -n "$row" ] || continue # that space no longer exists
    index=${row%%$'\t'*}
    cur=${row#*$'\t'}
    [ "$cur" = "$label" ] && continue
    yabai -m space "$index" --label "$label" >/dev/null 2>&1
  done <"$WM_PANE_MAP_FILE"
  return 0
}

# Make a pane visible on a display without moving keyboard focus.
#
# `display --space` is exactly the primitive C2 needs, and it sidesteps the
# ordering hazard noted in spec 9.6. It requires the scripting addition; if that
# is not loaded we fall back to `space --focus`, which also moves focus, so the
# caller's final focus step still lands correctly -- it just flickers.
wm_show_pane() {
  local idx=$1 label=$2
  yabai -m display "$idx" --space "$label" >/dev/null 2>&1 && return 0
  yabai -m space --focus "$label" >/dev/null 2>&1
}

# C2 -- paired workspace switching.
wm_workspace_focus() {
  local ws=$1 r u idx focus_idx=""
  if ! wm_valid_ws "$ws"; then
    wm_log "wm: unknown workspace '$ws'"
    return 1
  fi
  wm_ensure_live
  wm_set_active_ws "$ws"
  # Every live display is re-targeted; sticky displays are left alone.
  while IFS=$'\t' read -r r u idx; do
    [ -n "$r" ] || continue
    wm_show_pane "$idx" "$(wm_pane_label "$ws" "$r")"
    # Focus should land on the primary when it is live; otherwise on the
    # highest-priority display that is.
    [ -n "$focus_idx" ] || focus_idx=$idx
  done < <(wm_live_ranked)
  [ -n "$focus_idx" ] && yabai -m display --focus "$focus_idx" >/dev/null 2>&1
  return 0
}

# Destination rank for send-to-workspace (C5) and new-window placement (C7):
# the first pane of <ws> in priority order that contains no windows, else the
# primary pane. <exclude> is a window id to ignore when counting occupancy, so a
# window can be placed relative to panes it is not itself sitting in.
#
# Prints nothing and fails if no pane of <ws> exists yet (reconcile has not run);
# callers treat that as "leave the window where the platform put it".
wm_pick_pane_rank() {
  local ws=$1 exclude=${2:-} spaces r u idx label n first_existing=""
  spaces=$(yabai -m query --spaces 2>/dev/null) || return 1
  while IFS=$'\t' read -r r u idx; do
    [ -n "$r" ] || continue
    label=$(wm_pane_label "$ws" "$r")
    n=$(printf '%s' "$spaces" | jq --arg l "$label" --arg x "$exclude" '
          [ .[] | select(.label == $l) ] as $pane
          | if ($pane | length) == 0 then -1
            else [ $pane[0].windows[] | select(tostring != $x) ] | length
            end')
    [ "$n" = "-1" ] && continue
    [ -n "$first_existing" ] || first_existing=$r
    [ "$n" = "0" ] && { printf '%s\n' "$r"; return 0; }
  done < <(wm_attached_ranked)
  # Every pane occupied: fall back to the primary (spec C5 step 2).
  [ -n "$first_existing" ] || return 1
  printf '%s\n' "$first_existing"
}

# C10 -- move windows out of panes whose rank exceeds the number of attached
# displays into the lowest-priority surviving pane of the same workspace, so
# they are visible and tiled rather than stranded on a parked space.
wm_evacuate_orphans() {
  local rmax spaces wid label
  rmax=$(wm_display_count)
  [ "${rmax:-0}" -ge 1 ] || return 0
  spaces=$(yabai -m query --spaces 2>/dev/null) || return 0
  while IFS=$'\t' read -r wid label; do
    [ -n "$wid" ] || continue
    yabai -m window "$wid" --space "$label" >/dev/null 2>&1
  done < <(printf '%s' "$spaces" | jq -r --argjson rmax "$rmax" '
      .[]
      | select(.label | test("^wm\\.[^.]+\\.[0-9]+$"))
      | (.label | split(".")) as $p
      | select(($p[2] | tonumber) > $rmax)
      | .windows[]
      | "\(.)\twm.\($p[1]).\($rmax)"
    ')
  return 0
}

# The cheap subset of reconcile, safe to run automatically from a display
# signal: no space creation, so no animation storm. Re-homes panes that already
# exist to their rank's display, evacuates orphans, restores the C6 invariant
# and re-shows the active workspace.
#
# Because panes are parked rather than destroyed when a display goes away, this
# is enough to restore full multi-display behaviour on replug (item 25).
wm_adapt() {
  local spaces rows r u idx ws label cur
  # First, because everything below addresses panes by label.
  wm_relabel_panes
  rows=$(wm_attached_ranked)
  [ -n "$rows" ] || return 0
  spaces=$(yabai -m query --spaces 2>/dev/null) || return 0
  while IFS=$'\t' read -r r u idx; do
    [ -n "$r" ] || continue
    for ws in $WM_WS_KEYS; do
      label=$(wm_pane_label "$ws" "$r")
      cur=$(printf '%s' "$spaces" | jq -r --arg l "$label" '.[] | select(.label==$l) | .display')
      [ -n "$cur" ] || continue      # pane not created yet; wm-reconcile's job
      [ "$cur" = "$idx" ] && continue
      yabai -m space "$label" --display "$idx" >/dev/null 2>&1
    done
  done <<<"$rows"
  wm_evacuate_orphans
  wm_ensure_live
  wm_workspace_focus "$(wm_active_ws)"
  wm_save_pane_map
}

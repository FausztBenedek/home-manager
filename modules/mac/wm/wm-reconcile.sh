# shellcheck shell=bash
# Spec 3.3 -- bring the macOS spaces in line with the pane model.
#
# usage: wm-reconcile [--dry-run]
#
# Creates, labels and assigns one space per (workspace, attached display) pair,
# i.e. 18 x R panes labelled wm.<workspace>.<rank>. Idempotent: running it when
# nothing has changed reports "no changes" and touches nothing.
#
# Notes on the approach, all driven by the spec's scale note:
#
#   * Existing *unlabelled* spaces on a display are adopted before new ones are
#     created. Without this, a machine that already has spaces would end up with
#     those spaces plus 18 x R more.
#   * Adopted spaces are never moved between displays -- only created ones are
#     placed directly on their target display via `space --create <display>`.
#     Moving a display's last space away is refused by yabai, and this avoids
#     having to reason about it at all.
#   * Panes are addressed by label, never by mission-control index, because
#     indices shift as spaces are created and moved.
#   * Space creation is slow and animated, so it is paced.
#   * Spaces are never destroyed. When a display goes away its panes are parked
#     and their windows evacuated (see wm-adapt); replugging just moves the
#     parked panes back.

# shellcheck source=./wm-lib.sh
[ -n "${WM_LIB_LOADED:-}" ] || . "${WM_LIB:-$(dirname "$0")/wm-lib.sh}"

PACE=${WM_RECONCILE_PACE:-0.4}

dry=no
case "${1:-}" in
  --dry-run) dry=yes ;;
  "") ;;
  *)
    wm_log "usage: wm-reconcile [--dry-run]"
    exit 2
    ;;
esac

ranked=$(wm_attached_ranked)
if [ -z "$ranked" ]; then
  wm_log "wm-reconcile: yabai reported no displays"
  exit 1
fi

rmax=$(printf '%s\n' "$ranked" | grep -c .)
printf 'reconciling %s workspaces x %s display(s) = %s panes\n' \
  "$(printf '%s' "$WM_WS_KEYS" | wc -w | tr -d ' ')" "$rmax" \
  "$(($(printf '%s' "$WM_WS_KEYS" | wc -w) * rmax))"

# yabai forgets space labels when it restarts, so restore them from our own record
# before deciding what is missing -- otherwise every pane would look absent and be
# created a second time.
[ "$dry" = yes ] || wm_relabel_panes

spaces=$(yabai -m query --spaces)

# Unlabelled, non-fullscreen spaces available for adoption, as "<id>\t<display>".
mapfile -t adoptable < <(printf '%s' "$spaces" | jq -r '
  .[]
  | select((.label // "") == "")
  | select(.["is-native-fullscreen"] != true)
  | "\(.id)\t\(.display)"')

# Take an unlabelled space that already sits on <display index>, removing it from
# the pool and leaving its id in $taken. Fails when there is none, in which case
# the caller creates a space instead.
#
# The id is returned via a variable rather than stdout on purpose: a command
# substitution would run this in a subshell, and the removal from the pool would
# be lost -- which would hand the same space out once per workspace.
taken=""
take_adoptable_on() {
  local want=$1 i
  taken=""
  for i in "${!adoptable[@]}"; do
    if [ "${adoptable[$i]#*$'\t'}" = "$want" ]; then
      taken=${adoptable[$i]%%$'\t'*}
      unset 'adoptable[i]'
      return 0
    fi
  done
  return 1
}

# `space --label` selects by mission-control index, which shifts whenever a space
# is created, so resolve the stable id to an index immediately before labelling.
label_space_id() {
  local id=$1 label=$2 index
  index=$(yabai -m query --spaces | jq -r --argjson i "$id" '.[] | select(.id == $i) | .index')
  [ -n "$index" ] || return 1
  yabai -m space "$index" --label "$label"
}

created=0
adopted=0
moved=0
failed_moves=()

while IFS=$'\t' read -r rank uuid idx; do
  [ -n "$rank" ] || continue
  for ws in $WM_WS_KEYS; do
    label=$(wm_pane_label "$ws" "$rank")
    on_display=$(printf '%s' "$spaces" | jq -r --arg l "$label" '.[] | select(.label == $l) | .display')

    if [ -n "$on_display" ]; then
      # The pane exists. Make sure it is on the display that holds this rank.
      if [ "$on_display" != "$idx" ]; then
        if [ "$dry" = yes ]; then
          printf '  would move   %-10s display %s -> %s\n' "$label" "$on_display" "$idx"
        elif yabai -m space "$label" --display "$idx" >/dev/null 2>&1; then
          printf '  moved        %-10s -> display %s\n' "$label" "$idx"
        else
          # Usually "cannot move the last space off a display": retried below,
          # once the other moves have freed things up.
          failed_moves+=("$label|$idx")
        fi
        moved=$((moved + 1))
      fi
      continue
    fi

    if take_adoptable_on "$idx"; then
      if [ "$dry" = yes ]; then
        printf '  would adopt  %-10s existing space %s on display %s\n' "$label" "$taken" "$idx"
      elif label_space_id "$taken" "$label" >/dev/null 2>&1; then
        printf '  adopted      %-10s (space %s on display %s)\n' "$label" "$taken" "$idx"
      else
        wm_log "  FAILED to label space $taken as $label"
      fi
      adopted=$((adopted + 1))
      continue
    fi

    if [ "$dry" = yes ]; then
      printf '  would create %-10s on display %s\n' "$label" "$idx"
      created=$((created + 1))
      continue
    fi

    before=$(yabai -m query --spaces --display "$idx" | jq -r '.[].id' | sort)
    if ! yabai -m space --create "$idx" >/dev/null 2>&1; then
      wm_log "  FAILED to create a space on display $idx (is the scripting addition loaded?)"
      continue
    fi
    sleep "$PACE"
    after=$(yabai -m query --spaces --display "$idx" | jq -r '.[].id' | sort)
    new=$(comm -13 <(printf '%s\n' "$before") <(printf '%s\n' "$after") | grep -m1 .)
    if [ -z "$new" ]; then
      wm_log "  FAILED to identify the space just created on display $idx"
      continue
    fi
    if label_space_id "$new" "$label" >/dev/null 2>&1; then
      printf '  created      %-10s on display %s\n' "$label" "$idx"
    else
      wm_log "  FAILED to label space $new as $label"
    fi
    created=$((created + 1))
  done
done <<<"$ranked"

# Ordering cycles: moving rank-2 panes onto a display can require rank-3 panes to
# have vacated it first. One retry pass after every other move resolves that.
for entry in ${failed_moves+"${failed_moves[@]}"}; do
  label=${entry%%|*}
  idx=${entry##*|}
  if yabai -m space "$label" --display "$idx" >/dev/null 2>&1; then
    printf '  moved        %-10s -> display %s (retry)\n' "$label" "$idx"
  else
    wm_log "  FAILED to move $label to display $idx"
  fi
done

if [ "$dry" = no ]; then
  # Windows stranded on panes of ranks that no longer have a display.
  wm_evacuate_orphans
  wm_ensure_live
  wm_workspace_focus "$(wm_active_ws)"
  # Persist which space is which pane, so a yabai restart does not scramble it.
  wm_save_pane_map
fi

# ${#adoptable[@]} rather than expanding the array: take_adoptable_on unsets
# individual elements, and ${adoptable+...} keys off element 0, which is the
# first one consumed.
leftover=${#adoptable[@]}
if [ "$created" -eq 0 ] && [ "$adopted" -eq 0 ] && [ "$moved" -eq 0 ]; then
  printf 'no changes\n'
else
  printf 'created %s, adopted %s, moved %s\n' "$created" "$adopted" "$moved"
fi
[ "${leftover:-0}" -gt 0 ] && printf '%s unlabelled space(s) left alone\n' "$leftover"
exit 0

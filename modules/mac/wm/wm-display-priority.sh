# shellcheck shell=bash
# C11 -- assign priority ranks to the attached displays.
#
# usage:
#   wm-display-priority                  interactive, with on-screen cues
#   wm-display-priority --list           show the current assignment as text
#   wm-display-priority --set A C B       non-interactive; primary first
#   wm-display-priority --set <uuid>...   ditto, by stable identifier
#
# Priority order is the one thing about displays that cannot be derived from
# geometry, so it has to be stated. Displays are addressed by the letter shown in
# the cue (A = arrangement position 1, B = 2, ...), by arrangement index, or by
# UUID; all three resolve to the UUID, which is what gets stored. Nothing is ever
# keyed on enumeration order.
#
# Assignments live in mutable state outside the Nix store (see wm-lib.sh), so the
# generated configuration is never touched.

# shellcheck source=./wm-lib.sh
[ -n "${WM_LIB_LOADED:-}" ] || . "${WM_LIB:-$(dirname "$0")/wm-lib.sh}"

CUE_TITLE_PREFIX=yabai-wm-display-cue
CUE_FONT=${WM_CUE_FONT_SIZE:-72}
CUE_RULE=wm_display_cue
LETTERS=ABCDEFGHIJKLMNOP

# Distinct background colours. These only *reinforce* the letter -- the spec is
# explicit that colour must never be the sole distinguishing feature.
CUE_COLORS=(
  '#1b3b6f' '#6f1b2e' '#1b6f3a' '#6f5a1b' '#4a1b6f' '#1b5f6f'
)

cue_pids=()
cue_files=()

# Cues must be gone when the tool exits, including when it exits abnormally
# (item 33). Two layers: this trap, and a watchdog inside each cue process that
# exits as soon as this process disappears -- which covers even SIGKILL, where no
# trap can run.
cleanup_cues() {
  local p wid f
  yabai -m rule --remove "$CUE_RULE" >/dev/null 2>&1
  for p in ${cue_pids+"${cue_pids[@]}"}; do
    kill "$p" >/dev/null 2>&1
  done
  cue_pids=()
  for wid in $(yabai -m query --windows 2>/dev/null | jq -r --arg t "$CUE_TITLE_PREFIX" \
    '.[] | select(.title | startswith($t)) | .id'); do
    yabai -m window "$wid" --close >/dev/null 2>&1
  done
  for f in ${cue_files+"${cue_files[@]}"}; do
    rm -f "$f"
  done
  cue_files=()
}
trap cleanup_cues EXIT INT TERM HUP

num_to_letter() { printf '%s\n' "$LETTERS" | cut -c"$1"; }

letter_to_num() {
  printf '%s' "$LETTERS" | awk -v c="$(printf '%s' "$1" | tr '[:lower:]' '[:upper:]')" \
    '{ print index($0, c) }'
}

rank_of_uuid() {
  local uuid=$1 r u idx
  while IFS=$'\t' read -r r u idx; do
    [ "$u" = "$uuid" ] && { printf '%s\n' "$r"; return 0; }
  done < <(wm_attached_ranked)
  printf 'unassigned\n'
}

rank_name() {
  case "$1" in
    1) printf 'primary\n' ;;
    2) printf 'secondary\n' ;;
    3) printf 'tertiary\n' ;;
    unassigned) printf 'unassigned\n' ;;
    *) printf 'rank %s\n' "$1" ;;
  esac
}

# ---------------------------------------------------------------------------
# text listing -- also the documented fallback when no overlay mechanism is
# available, since the visual cue is only a SHOULD
# ---------------------------------------------------------------------------

list_displays() {
  local dj idx uuid w h rank
  dj=$(wm_query_displays)
  printf '%-4s %-4s %-38s %-12s %s\n' CUE IDX UUID PRIORITY RESOLUTION
  while IFS=$'\t' read -r idx uuid w h; do
    [ -n "$idx" ] || continue
    rank=$(rank_of_uuid "$uuid")
    printf '%-4s %-4s %-38s %-12s %sx%s\n' \
      "$(num_to_letter "$idx")" "$idx" "$uuid" "$(rank_name "$rank")" "$w" "$h"
  done < <(printf '%s' "$dj" | jq -r '.[] | "\(.index)\t\(.uuid)\t\(.frame.w|floor)\t\(.frame.h|floor)"')
}

# ---------------------------------------------------------------------------
# visual identification
# ---------------------------------------------------------------------------

# Show a large, unambiguous identifier on every attached display at the same
# time, each stating that display's current priority. Placement uses the ability
# to put a window on a chosen display, which the spec already mandates via C4/C5.
show_cues() {
  local dj idx uuid w h rank letter colour file wid
  command -v alacritty >/dev/null 2>&1 || return 1

  yabai -m rule --add label="$CUE_RULE" title="^$CUE_TITLE_PREFIX" manage=off >/dev/null 2>&1

  dj=$(wm_query_displays)
  while IFS=$'\t' read -r idx uuid w h; do
    [ -n "$idx" ] || continue
    letter=$(num_to_letter "$idx")
    rank=$(rank_of_uuid "$uuid")
    colour=${CUE_COLORS[$(((idx - 1) % ${#CUE_COLORS[@]}))]}

    file=$(mktemp "${TMPDIR:-/tmp}/wm-cue.XXXXXX")
    cue_files+=("$file")
    {
      printf '\n  %s\n\n' "$letter"
      printf '  %s\n' "$(rank_name "$rank")"
      printf '  %sx%s\n' "$w" "$h"
    } >"$file"

    alacritty -T "$CUE_TITLE_PREFIX-$letter" \
      -o "font.size=$CUE_FONT" \
      -o "colors.primary.background='$colour'" \
      -o "colors.primary.foreground='#ffffff'" \
      -o "window.padding.x=40" \
      -o "window.padding.y=40" \
      -e /bin/sh -c "cat '$file'; while kill -0 $$ 2>/dev/null; do sleep 1; done" \
      >/dev/null 2>&1 &
    cue_pids+=("$!")

    # Park the cue on the display it identifies.
    wid=""
    for _ in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
      sleep 0.2
      wid=$(yabai -m query --windows 2>/dev/null | jq -r --arg t "$CUE_TITLE_PREFIX-$letter" \
        '.[] | select(.title == $t) | .id' | grep -m1 .)
      [ -n "$wid" ] && break
    done
    if [ -n "$wid" ]; then
      yabai -m window "$wid" --display "$idx" >/dev/null 2>&1
      yabai -m window "$wid" --grid 3:3:1:1:1:1 >/dev/null 2>&1
    fi
  done < <(printf '%s' "$dj" | jq -r '.[] | "\(.index)\t\(.uuid)\t\(.frame.w|floor)\t\(.frame.h|floor)"')
  return 0
}

# ---------------------------------------------------------------------------
# assignment
# ---------------------------------------------------------------------------

resolve_ident() {
  local id=$1 dj=$2 n
  if printf '%s' "$dj" | jq -e --arg u "$id" 'any(.[]; .uuid == $u)' >/dev/null 2>&1; then
    printf '%s\n' "$id"
    return 0
  fi
  case "$id" in
    [0-9] | [0-9][0-9]) n=$id ;;
    [A-Za-z]) n=$(letter_to_num "$id") ;;
    *) return 1 ;;
  esac
  [ "${n:-0}" -ge 1 ] 2>/dev/null || return 1
  printf '%s' "$dj" | jq -r --argjson n "$n" '.[] | select(.index == $n) | .uuid' | grep -m1 .
}

# Write the priority file: the given UUIDs in the given order, then every other
# UUID we already knew about, in its existing order. Keeping detached displays is
# what makes priorities survive unplugging and replugging in a different order
# (item 30).
#
# Returns 0 if the file changed, 1 if it was already exactly this.
store_priority() {
  local ordered=$1 stored="" u
  [ -f "$WM_PRIORITY_FILE" ] && stored=$(grep -v '^[[:space:]]*$' "$WM_PRIORITY_FILE")
  {
    printf '%s\n' "$ordered"
    while IFS= read -r u; do
      [ -n "$u" ] || continue
      printf '%s\n' "$ordered" | grep -qxF -- "$u" || printf '%s\n' "$u"
    done <<<"$stored"
  } | wm_write_state "$WM_PRIORITY_FILE"
}

apply_and_offer_reconcile() {
  local changed=$1
  if [ "$changed" != changed ]; then
    printf 'priority unchanged\n'
    return 0
  fi
  printf 'priority updated:\n'
  list_displays
  # Which pane belongs to which display depends on priority, so the panes have to
  # be re-homed. wm-adapt is the cheap half and is always safe; a full reconcile
  # is only needed when panes are missing.
  wm_adapt
  printf '\nPanes re-homed. Run "wm-reconcile" if any pane is still missing.\n'
}

set_priority_from_args() {
  local dj uuid ordered="" id
  dj=$(wm_query_displays)
  for id in "$@"; do
    uuid=$(resolve_ident "$id" "$dj") || {
      wm_log "wm-display-priority: cannot resolve display '$id'"
      return 2
    }
    if [ -n "$uuid" ] && printf '%s\n' "$ordered" | grep -qxF -- "$uuid"; then
      wm_log "wm-display-priority: display '$id' given twice"
      return 2
    fi
    [ -n "$uuid" ] || {
      wm_log "wm-display-priority: cannot resolve display '$id'"
      return 2
    }
    if [ -n "$ordered" ]; then ordered="$ordered
$uuid"; else ordered=$uuid; fi
  done
  if store_priority "$ordered"; then
    apply_and_offer_reconcile changed
  else
    apply_and_offer_reconcile unchanged
  fi
}

interactive() {
  local dj letters count answer tok n ok idents
  dj=$(wm_query_displays)
  count=$(printf '%s' "$dj" | jq 'length')
  letters=""
  for n in $(seq 1 "$count"); do letters="$letters$(num_to_letter "$n") "; done

  show_cues || printf 'alacritty not available; identifying displays textually instead.\n\n'
  list_displays
  printf '\n'

  while :; do
    printf 'Priority order, primary first (letters: %s) or blank to keep: ' "$letters"
    IFS= read -r answer || answer=""
    if [ -z "${answer// /}" ]; then
      printf 'unchanged\n'
      return 0
    fi
    # shellcheck disable=SC2086
    set -- $answer
    if [ $# -ne "$count" ]; then
      printf 'Expected %s entries, got %s.\n' "$count" "$#"
      continue
    fi
    ok=yes
    idents=()
    for tok in "$@"; do
      if resolve_ident "$tok" "$dj" >/dev/null 2>&1; then
        idents+=("$tok")
      else
        printf 'Unknown display "%s".\n' "$tok"
        ok=no
        break
      fi
    done
    [ "$ok" = yes ] || continue
    break
  done

  if store_priority "$(
    for tok in "${idents[@]}"; do resolve_ident "$tok" "$dj"; done
  )"; then
    # Redisplay the cues so the new priorities can be confirmed on screen.
    cleanup_cues
    trap cleanup_cues EXIT INT TERM HUP
    show_cues || true
    apply_and_offer_reconcile changed
    printf '\nPress return to dismiss the cues. '
    IFS= read -r _ || true
  else
    apply_and_offer_reconcile unchanged
  fi
}

case "${1:-}" in
  --list)
    list_displays
    ;;
  --set)
    shift
    [ $# -ge 1 ] || {
      wm_log "usage: wm-display-priority --set <display>... (primary first)"
      exit 2
    }
    set_priority_from_args "$@"
    ;;
  -h | --help)
    cat <<'EOF'
usage:
  wm-display-priority                   interactive, with on-screen cues
  wm-display-priority --list            show the current assignment as text
  wm-display-priority --set A C B       non-interactive; primary first
  wm-display-priority --set <uuid>...   ditto, by stable identifier

Displays can be named by their cue letter (A = arrangement position 1), by
arrangement index, or by UUID. The UUID is what gets stored, in
$XDG_STATE_HOME/yabai-wm/display-priority.
EOF
    ;;
  "")
    interactive
    ;;
  *)
    wm_log "usage: wm-display-priority [--list | --set <display>...]"
    exit 2
    ;;
esac

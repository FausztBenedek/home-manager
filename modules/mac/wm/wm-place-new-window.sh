# shellcheck shell=bash
# C7 -- place a newly created window using the C5 rule.
#
# usage: wm-place-new-window <window-id>
# Wired to yabai's window_created signal, which passes $YABAI_WINDOW_ID.
#
# The spec marks this SHOULD, not MUST, because the hook is known to fire before
# placement has settled. Two mitigations, both named in spec C7:
#
#   * a short delay plus one retry before the window is queried at all;
#   * if the window did not land on a pane of the active workspace, we leave it
#     alone. That is the mandated fallback to native placement, and it is also
#     what keeps windows opened deliberately onto a sticky display, or onto a
#     space outside this model, from being yanked away.

# shellcheck source=./wm-lib.sh
[ -n "${WM_LIB_LOADED:-}" ] || . "${WM_LIB:-$(dirname "$0")/wm-lib.sh}"

wid=${1:-}
[ -n "$wid" ] || exit 0

win=""
for delay in 0.2 0.5; do
  sleep "$delay"
  win=$(yabai -m query --windows --window "$wid" 2>/dev/null)
  [ -n "$win" ] && break
done
[ -n "$win" ] || exit 0

# Floating, minimised and sticky windows are not tiled into panes; the display
# identification cues of C11 are floating too, and must never be relocated.
if printf '%s' "$win" | jq -e '
      .["is-floating"] or .["is-minimized"] or .["is-sticky"]
      or (.title | startswith("yabai-wm-display-cue"))' >/dev/null 2>&1; then
  exit 0
fi

space_index=$(printf '%s' "$win" | jq -r '.space // empty')
[ -n "$space_index" ] || exit 0

current_label=$(yabai -m query --spaces --space "$space_index" 2>/dev/null | jq -r '.label // empty')
ws=$(wm_active_ws)

# Fall back to native placement unless the window is on a pane of the active
# workspace.
case "$current_label" in
  "wm.$ws."*) ;;
  *) exit 0 ;;
esac

rank=$(wm_pick_pane_rank "$ws" "$wid") || exit 0
target=$(wm_pane_label "$ws" "$rank")
[ "$target" = "$current_label" ] && exit 0

yabai -m window "$wid" --space "$target" >/dev/null 2>&1 || exit 0
# The window was just opened, so focus belongs with it wherever it ended up.
yabai -m window --focus "$wid" >/dev/null 2>&1
exit 0

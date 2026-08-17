# shellcheck shell=bash
# C4 -- move the focused window one step in a direction, carrying focus with it.
#
# usage: wm-move-dir north|south|east|west
#
# Within a pane this is a pure exchange of positions (item 9) and consults no
# priority order. At the pane's edge -- which is exactly when `window --swap`
# fails -- the window crosses into whatever pane the spatially adjacent display
# is currently showing, including when that display is sticky and therefore
# showing a different workspace. The spec requires that case to work and not be
# special-cased.

# shellcheck source=./wm-lib.sh
[ -n "${WM_LIB_LOADED:-}" ] || . "${WM_LIB:-$(dirname "$0")/wm-lib.sh}"

case "${1:-}" in
  north | south | east | west) dir=$1 ;;
  *)
    wm_log "usage: wm-move-dir north|south|east|west"
    exit 2
    ;;
esac

wid=$(yabai -m query --windows --window 2>/dev/null | jq -r '.id // empty')
[ -n "$wid" ] || exit 0

yabai -m window --swap "$dir" >/dev/null 2>&1 && exit 0

# No display in that direction either: nothing happens, no wrap.
yabai -m window "$wid" --display "$dir" >/dev/null 2>&1 || exit 0
# `window --display` does not move focus, so bring it along explicitly.
yabai -m window --focus "$wid" >/dev/null 2>&1
exit 0

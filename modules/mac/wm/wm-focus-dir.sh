# shellcheck shell=bash
# C3 -- directional focus, crossing display boundaries.
#
# usage: wm-focus-dir north|south|east|west
#
# yabai's `window --focus <dir>` stops at the edge of the current space, so we
# fall back to `display --focus <dir>`, which uses yabai's own geometric
# adjacency resolution -- the perpendicular-overlap-then-nearest rule of spec
# 3.2, in all four directions. That also means rearranging monitors in System
# Settings takes effect with no config change (item 26).
#
# Both commands failing means there is nothing in that direction: no wrap
# (item 7), and no error either.

# shellcheck source=./wm-lib.sh
[ -n "${WM_LIB_LOADED:-}" ] || . "${WM_LIB:-$(dirname "$0")/wm-lib.sh}"

case "${1:-}" in
  north | south | east | west) dir=$1 ;;
  *)
    wm_log "usage: wm-focus-dir north|south|east|west"
    exit 2
    ;;
esac

yabai -m window --focus "$dir" >/dev/null 2>&1 && exit 0
# Moves focus to the adjacent display even when the pane it shows is empty
# (item 6).
yabai -m display --focus "$dir" >/dev/null 2>&1
exit 0

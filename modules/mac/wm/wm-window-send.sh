# shellcheck shell=bash
# C5 -- send the focused window to a workspace, choosing the pane by priority.
#
# usage: wm-window-send <workspace-key> [--follow]
#
# Unlike C4 this is not directional: the destination is the first pane of the
# target workspace, in priority order, that contains no windows; if every pane is
# occupied, the primary pane (items 10-12).
#
#   plain      the window moves; focus and the active workspace do not change
#   --follow   the window moves, then the workspace is activated per C2

# shellcheck source=./wm-lib.sh
[ -n "${WM_LIB_LOADED:-}" ] || . "${WM_LIB:-$(dirname "$0")/wm-lib.sh}"

ws=${1:-}
follow=no
[ "${2:-}" = "--follow" ] && follow=yes

if ! wm_valid_ws "$ws"; then
  wm_log "usage: wm-window-send <workspace-key> [--follow]   (one of: $WM_WS_KEYS)"
  exit 2
fi

wid=$(yabai -m query --windows --window 2>/dev/null | jq -r '.id // empty')
[ -n "$wid" ] || exit 0

# The window must not count itself when occupancy is measured, so sending a
# window to the workspace it already occupies is a no-op rather than a bump to
# the next pane.
if rank=$(wm_pick_pane_rank "$ws" "$wid"); then
  yabai -m window "$wid" --space "$(wm_pane_label "$ws" "$rank")" >/dev/null 2>&1
else
  # No pane of that workspace exists yet -- wm-reconcile has not been run.
  wm_log "wm: workspace '$ws' has no panes yet; run wm-reconcile"
fi

[ "$follow" = yes ] && wm_workspace_focus "$ws"
exit 0

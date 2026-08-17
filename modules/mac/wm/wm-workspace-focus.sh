# shellcheck shell=bash
# C2 -- activate a workspace on every non-sticky display at once.
#
# usage: wm-workspace-focus <workspace-key>

# shellcheck source=./wm-lib.sh
[ -n "${WM_LIB_LOADED:-}" ] || . "${WM_LIB:-$(dirname "$0")/wm-lib.sh}"

if [ $# -ne 1 ]; then
  wm_log "usage: wm-workspace-focus <workspace-key>   (one of: $WM_WS_KEYS)"
  exit 2
fi

wm_workspace_focus "$1"

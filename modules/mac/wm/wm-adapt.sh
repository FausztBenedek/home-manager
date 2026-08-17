# shellcheck shell=bash
# Re-align panes with the currently attached displays. No space creation.
#
# usage: wm-adapt
#
# Run automatically from the display_added / display_removed / display_moved
# signals and once at the end of yabairc. Cheap enough to be automatic, which is
# what makes the following hold without user action:
#
#   * item 19 -- unplugging the only live display leaves another one live
#   * item 23 -- windows on a departing display reappear, tiled, on a survivor
#   * item 25 -- replugging restores full behaviour without a reconcile step,
#                because panes are parked rather than destroyed
#
# Creating missing panes is wm-reconcile's job, since space creation on macOS is
# slow and animated and spec 3.3 says reconcile SHOULD NOT be automatic.

# shellcheck source=./wm-lib.sh
[ -n "${WM_LIB_LOADED:-}" ] || . "${WM_LIB:-$(dirname "$0")/wm-lib.sh}"

wm_adapt

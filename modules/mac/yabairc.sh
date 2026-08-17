# yabai configuration for the workflow specified in
# modules/window-manager-spec.md. See modules/mac/window-manager-README.md.
#
# for this to work you must configure sudo such that
# it will be able to run the command without password
# See https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition

yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
sudo yabai --load-sa

yabai -m config layout bsp

# Gap, padding and border dimensions are out of scope per section 7 of the spec.
# This is repeated in the generated skhdrc when leaving the gaps-off mode.
yabai -m config top_padding 5 config bottom_padding 5 config left_padding 5 config right_padding 5 config window_gap 15

# set focus follows mouse mode (default: off, options: off, autoraise, autofocus)
yabai -m config focus_follows_mouse autoraise
# set mouse follows focus mode (default: off)
yabai -m config mouse_follows_focus on

# C7 -- keep new windows on the display that has focus, so wm-place-new-window
# starts from a predictable position instead of racing the cursor.
yabai -m config window_origin_display focused

# ---------------------------------------------------------------------------
# Panes
#
# Panes (spec 3.3) are macOS spaces labelled wm.<workspace>.<rank>. They are
# created on demand by `wm-reconcile`, not here: 18 workspaces x N displays is up
# to 54 spaces, and creating them is slow and animated, so the spec says the
# reconcile operation should not be required to run automatically.
#
# `wm-adapt` is the cheap half -- it re-homes panes that already exist, evacuates
# windows from panes whose display has gone away, and enforces the C6 "at least
# one live display" invariant. That is safe to run automatically.
# ---------------------------------------------------------------------------

# C7 -- new window placement by priority order.
yabai -m signal --add event=window_created action="wm-place-new-window \$YABAI_WINDOW_ID"

# C10 and the C6 invariant: react to monitors coming and going without any user
# action (spec conformance items 19, 23, 25).
yabai -m signal --add event=display_added action="wm-adapt"
yabai -m signal --add event=display_removed action="wm-adapt"
yabai -m signal --add event=display_moved action="wm-adapt"

# ---------------------------------------------------------------------------
# Nested sessions (spec section 6)
#
# The guest enters its own mode with ctrl-n while the host uses ctrl-m, so the two
# layers cannot collide. These signals tell kanata to switch layers when the
# remote desktop client takes or loses focus.
# ---------------------------------------------------------------------------
yabai -m signal --add event=application_activated app="Omnissa Horizon Client" action="echo '{\"ChangeLayer\":{\"new\":\"in-vm\"}}' | nc -w1 localhost 15829"
yabai -m signal --add event=application_deactivated app="Omnissa Horizon Client" action="echo '{\"ChangeLayer\":{\"new\":\"hu\"}}' | nc -w1 localhost 15829"

# Register any newly seen display, re-home existing panes and show the active
# workspace. Harmless before the first `wm-reconcile`, when there are no panes yet.
wm-adapt

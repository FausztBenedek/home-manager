# for this to work you must configure sudo such that
# it will be able to run the command without password
# See https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition

yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
sudo yabai --load-sa

yabai -m config layout bsp

# Set all padding and gaps to 20pt (default: 0)
yabai -m config top_padding 5
yabai -m config bottom_padding 5
yabai -m config left_padding 5
yabai -m config right_padding 5
yabai -m config window_gap 15

# set focus follows mouse mode (default: off, options: off, autoraise, autofocus)
yabai -m config focus_follows_mouse autoraise
# set mouse follows focus mode (default: off)
yabai -m config mouse_follows_focus on

NEEDED_SPACES=19
REMAINING_SPACES=$(expr $NEEDED_SPACES - $(yabai -m query --spaces | jq '. | length'))

for ((i = 1; i <= REMAINING_SPACES; i++)); do
	yabai -m space --create
done


focus_window () {
    SPACE_NAME=$(yabai -m query --spaces --space | jq ".label")
    WINDOW_ID=$(yabai -m query --windows --space | jq ".[] | select (.app=${SPACE_NAME}).id")
    yabai -m window --focus "${WINDOW_ID}"
}

# focus window after active space changes
yabai -m signal --add event=space_changed action="focus_window"

# focus window after active display changes
yabai -m signal --add event=display_changed action="focus_window"

# Place workspaces on other monitor with yabai
yabai -m query --spaces | jq ".[] | select(.display==1) | .index" | while read -r SPACE_ID; do echo "SPACE_ID=$SPACE_ID"; yabai -m space $SPACE_ID --display 2; done


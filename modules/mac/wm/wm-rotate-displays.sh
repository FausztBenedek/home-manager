# shellcheck shell=bash
# C12 -- move the active workspace's windows from each live display to the next.
#
# usage: wm-rotate-displays
#
# Only *live* displays take part (C12 "Which displays participate"): a sticky
# display is deliberately showing another workspace's pane by the user's request
# (C6), so rotating that pane away would undo the toggle just pressed. With fewer
# than two live displays this is a no-op, which is also the single-display case of
# C10.
#
# The cycle order is *reading order*, derived from the monitor geometry the
# platform reports -- rows by overlapping vertical extent, rows top to bottom,
# left to right within a row. It is emphatically **not** priority order, so
# wm_live_ranked is used only to decide *which* displays participate and to name
# their panes; the order comes from the frames in wm_query_displays. Rearranging
# monitors in System Settings therefore changes the cycle with no config change
# (item 45), exactly as it already changes adjacency for C3/C4 (item 26).
#
# Windows are moved between *panes*, never panes between displays: pane
# wm.<ws>.<rank> stays on the display of rank <rank>, so priority order is
# untouched and C5/C7 keep placing windows on the same physical monitor as before
# (item 43). Panes of other workspaces are never addressed (item 42).

# shellcheck source=./wm-lib.sh
[ -n "${WM_LIB_LOADED:-}" ] || . "${WM_LIB:-$(dirname "$0")/wm-lib.sh}"

live=$(wm_live_ranked)
[ "$(printf '%s\n' "$live" | grep -c .)" -ge 2 ] || exit 0

displays=$(wm_query_displays)
[ -n "$displays" ] || exit 0

# Reading order over the live displays. Sorting by top edge first means each row
# is opened by its topmost display, so rows come out top to bottom; a display
# joins the row it vertically overlaps and otherwise opens the next one.
live_json=$(printf '%s\n' "$live" | cut -f2 | jq -Rsc 'split("\n") | map(select(. != ""))')
order=$(printf '%s' "$displays" | jq -r --argjson live "$live_json" '
  [ .[] | select(.uuid as $u | $live | index($u) != null) ]
  | sort_by(.frame.y, .frame.x)
  | reduce .[] as $d ([];
      if length == 0 then [ [ $d ] ]
      elif ($d.frame.y < (.[-1] | map(.frame.y + .frame.h) | max))
           and ((.[-1] | map(.frame.y) | min) < ($d.frame.y + $d.frame.h))
      then .[0:-1] + [ .[-1] + [ $d ] ]
      else . + [ [ $d ] ]
      end)
  | map(sort_by(.frame.x))
  | .[][].uuid')
[ -n "$order" ] || exit 0

ws=$(wm_active_ws)
spaces=$(yabai -m query --spaces 2>/dev/null) || exit 0

# Snapshot every participating display's window set *before* anything moves.
# Moving display by display without this is the trap spec 9.10 names: windows
# moved into a display would be picked up again and carried on to the next one.
#
# A pane's `windows` is its whole membership, floating windows included, which is
# what C12 asks to travel.
labels=()
wins=()
while IFS= read -r uuid; do
  [ -n "$uuid" ] || continue
  rank=$(printf '%s\n' "$live" | awk -F'\t' -v u="$uuid" '$2 == u { print $1; exit }')
  label=$(wm_pane_label "$ws" "$rank")
  if ! printf '%s' "$spaces" | jq -e --arg l "$label" 'any(.[]; .label == $l)' >/dev/null; then
    wm_log "wm: workspace '$ws' has no pane $label yet; run wm-reconcile"
    exit 0
  fi
  labels+=("$label")
  wins+=("$(printf '%s' "$spaces" | jq -r --arg l "$label" \
    '.[] | select(.label == $l) | .windows[]')")
done <<<"$order"

n=${#labels[@]}
[ "$n" -ge 2 ] || exit 0

# Focus stays on the window, not on the physical screen (spec 9.6), so remember
# it now and put it back at the end -- moving windows between spaces disturbs
# focus, and the focused window may itself be one of the movers.
focused=$(yabai -m query --windows --window 2>/dev/null | jq -r '.id // empty')

# `window --space` names the destination pane rather than trusting what the
# destination display happens to be showing, and it needs no companion command:
# on a cross-display move yabai re-frames the window itself, floating windows
# included -- it moves them relative to the new display origin and clamps them if
# the destination is smaller. Verified on yabai 7.1.25.
for ((i = 0; i < n; i++)); do
  d=$(((i + 1) % n))
  [ -n "${wins[$i]}" ] || continue
  while IFS= read -r wid; do
    [ -n "$wid" ] || continue
    yabai -m window "$wid" --space "${labels[$d]}" >/dev/null 2>&1
  done <<<"${wins[$i]}"
done

[ -n "$focused" ] && yabai -m window --focus "$focused" >/dev/null 2>&1
exit 0

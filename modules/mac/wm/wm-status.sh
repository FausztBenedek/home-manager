# shellcheck shell=bash
# Report the current state of the window manager.
#
# usage: wm-status
#
# Not required by the spec. It exists because walking the spec's 40-item
# conformance checklist by hand is far easier when active workspace, effective
# ranks, the sticky set and the visible pane of each display can be read in one
# shot.

# shellcheck source=./wm-lib.sh
[ -n "${WM_LIB_LOADED:-}" ] || . "${WM_LIB:-$(dirname "$0")/wm-lib.sh}"

ws=$(wm_active_ws)
spaces=$(yabai -m query --spaces 2>/dev/null)
displays=$(wm_query_displays)
rmax=$(wm_display_count)

printf 'active workspace : %s\n' "$ws"
printf 'workspace keys   : %s\n' "$WM_WS_KEYS"
printf 'state dir        : %s\n' "$WM_STATE_DIR"
printf '\n'
printf '%-4s %-38s %-4s %-7s %-12s %s\n' RANK UUID IDX STICKY PANE RESOLUTION
while IFS=$'\t' read -r rank uuid idx; do
  [ -n "$rank" ] || continue
  if wm_is_sticky "$uuid"; then sticky=yes; else sticky=no; fi
  # An unlabelled space reports label "" rather than null, so `//` will not do.
  visible=$(printf '%s' "$spaces" | jq -r --argjson d "$idx" \
    '.[] | select(.display == $d) | select(.["is-visible"])
         | if (.label // "") == "" then "(unlabelled)" else .label end')
  res=$(printf '%s' "$displays" | jq -r --arg u "$uuid" \
    '.[] | select(.uuid == $u) | "\(.frame.w | floor)x\(.frame.h | floor)"')
  printf '%-4s %-38s %-4s %-7s %-12s %s\n' \
    "$rank" "$uuid" "$idx" "$sticky" "${visible:-?}" "$res"
done < <(wm_attached_ranked)

created=$(printf '%s' "$spaces" | jq -r \
  '[ .[] | select(.label | test("^wm\\.[^.]+\\.[0-9]+$")) ] | length')
# Panes whose rank exceeds the number of attached displays: parked rather than
# destroyed, which is what makes replugging cheap.
parked=$(printf '%s' "$spaces" | jq -r --argjson r "$rmax" \
  '[ .[] | select(.label | test("^wm\\.[^.]+\\.[0-9]+$"))
         | select((.label | split(".") | .[2] | tonumber) > $r) ] | length')

printf '\npanes: %s labelled, %s expected for %s attached display(s), %s parked\n' \
  "$created" "$(($(printf '%s' "$WM_WS_KEYS" | wc -w) * rmax))" "$rmax" "$parked"

printf '\npanes of the active workspace:\n'
for rank in $(wm_attached_ranked | cut -f1); do
  label=$(wm_pane_label "$ws" "$rank")
  printf '  %-10s %s\n' "$label" "$(printf '%s' "$spaces" | jq -r --arg l "$label" '
    [ .[] | select(.label == $l) ] as $p
    | if ($p | length) == 0 then "missing (run wm-reconcile)"
      else "\($p[0].windows | length) window(s)" end')"
done

# shellcheck shell=bash
# C6 -- toggle whether the focused display follows workspace switches.
#
# usage: wm-sticky-toggle
#
# The C6 invariant is that at no point may every attached display be sticky. We
# uphold it by refusing the toggle when the focused display is the last live one.
# The spec requires that this produce no error (items 17, 18), so the refusal is
# silent apart from a note on stderr.

# shellcheck source=./wm-lib.sh
[ -n "${WM_LIB_LOADED:-}" ] || . "${WM_LIB:-$(dirname "$0")/wm-lib.sh}"

uuid=$(wm_focused_display_uuid)
[ -n "$uuid" ] || exit 0

row=$(wm_attached_ranked | awk -F'\t' -v u="$uuid" '$2 == u { print; exit }')
rank=$(printf '%s' "$row" | cut -f1)
idx=$(printf '%s' "$row" | cut -f3)

if wm_is_sticky "$uuid"; then
  wm_sticky_uuids | grep -vxF -- "$uuid" | wm_set_sticky
  # On un-sticking, snap immediately to this display's pane of the active
  # workspace rather than waiting for the next switch.
  if [ -n "$rank" ] && [ -n "$idx" ]; then
    wm_show_pane "$idx" "$(wm_pane_label "$(wm_active_ws)" "$rank")"
  fi
  wm_log "wm: display $rank is live"
else
  if [ "$(wm_live_ranked | grep -c .)" -le 1 ]; then
    wm_log "wm: display $rank is the last live display; staying live"
    exit 0
  fi
  { wm_sticky_uuids; printf '%s\n' "$uuid"; } | wm_set_sticky
  wm_log "wm: display $rank is sticky"
fi
exit 0

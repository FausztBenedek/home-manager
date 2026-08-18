# yabai + skhd implementation of the window manager spec

This is the macOS half of [`../window-manager-spec.md`](../window-manager-spec.md).
The spec is normative in all three of its parts — capabilities, behaviour and key
bindings — because the point is that the same keypress does the same thing here,
on Hyprland and on GlazeWM.

## Deviations from section 5

**None.**

Section 5 permits a binding to differ only where the OS reserves the key
combination and the reservation cannot be disabled. Nothing in the table is
reserved by macOS, so nothing is substituted.

One consequence is worth stating plainly rather than hiding: the mode entry key
`ctrl-m` is `Return`. While skhd is running it captures `ctrl-m` globally, so
`Ctrl-M`-as-Enter stops working in terminals, Vim and everything else. That is a
cost of conforming, not a deviation. `option.mac.yabai.modeEntryKey` exists
because C1 requires the entry key to be configurable; the only two conforming
values are `ctrl - m` (host) and `ctrl - n` (guest, section 6).

`ctrl-a` also enters and leaves the mode, via
`option.mac.yabai.modeEntryKeyAliases`. This is an **addition, not a deviation**:
section 5's key is bound and does what the table says, nothing in the table is
remapped or absent, and `a` carries no other meaning in the scheme. It is here
because it was the entry key before the spec existed. Note that the guest's
`ctrl-n` (section 6) is deliberately *not* aliased — aliasing it on the host would
break the one thing section 6 asks for.

Two things in the generated `skhdrc` are outside the spec rather than in conflict
with it, both because section 7 puts them out of scope: the jankyborders colour
change on mode entry, and the gaps-off mode on `ctrl-\``.

## Key mapping as implemented

Diff this table against the equivalent one on the other platforms — that is
conformance item 38.

| Action | Key pressed | skhd spelling | Implementation |
| --- | --- | --- | --- |
| Enter mode | `ctrl-m` | `ctrl - m` | skhd mode `windowmanager` |
| Enter mode (alias, not in §5) | `ctrl-a` | `ctrl - a` | ditto — see below |
| Exit mode | `escape`, `ctrl-m` or `ctrl-a` | `escape` | — |
| Directional focus | `h` `j` `k` `l` | same | `wm-focus-dir west/south/north/east` |
| …and exit | `ctrl-h/j/k/l` | same | ditto, preceded by `skhd -k escape` |
| Directional move | `shift-h/j/k/l` | same | `wm-move-dir …` |
| …and exit | `ctrl-shift-h/j/k/l` | same | ditto |
| Switch to workspace | *workspace key* | see below | `wm-workspace-focus <ws>` |
| …and exit | `ctrl-`*key* | | ditto |
| Send window to workspace | `shift-`*key* | | `wm-window-send <ws>` |
| Send and follow, exit | `ctrl-shift-`*key* | | `wm-window-send <ws> --follow` |
| Toggle display stickiness | `9` / `ctrl-9` | `0x19` | `wm-sticky-toggle` |
| Rotate display contents | `o` / `ctrl-o` | same | `wm-rotate-displays` |
| Fullscreen toggle | `f` / `ctrl-f` | same | `yabai -m window --toggle zoom-fullscreen` |
| Float toggle | `z` / `ctrl-z` | same | `yabai -m window --toggle float` |
| Toggle split direction | `i` / `ctrl-i` | same | `yabai -m window --toggle split` |
| Balance panes | `shift-7` | `shift - 0x1A` | `yabai -m space --balance` |
| Resize | `alt-h/j/k/l` | same | `yabai -m window --resize …` |
| Directional focus, globally | `ctrl-cmd-h/j/k/l` | same | `wm-focus-dir …` — the one addition section 5 permits |

Each of these is bound twice. Section 5 names one half of the pair — `ctrl-9` for
stickiness, bare `f`, `z` and `o` for the rest — and C1 requires the other, so
`9`, `i` and `shift-7` are stay-in-mode halves while `ctrl-f`, `ctrl-z` and
`ctrl-o` are act-and-exit halves.

Workspace keys, and how skhd spells them on
`mac/us-benedek-xkb-querty.keylayout` (skhd matches physical keycodes, so digits
are written in hex — this is notation, not deviation):

| ws | `q` | `w` | `e` | `r` | `t` | `s` | `d` | `g` | `y` | `x` | `c` | `v` | `0` | `1` | `2` | `3` | `4` | `5` |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| skhd | `q` | `w` | `e` | `r` | `t` | `s` | `d` | `g` | `y` | `x` | `c` | `v` | `0x0A` | `0x12` | `0x13` | `0x14` | `0x15` | `0x17` |

## How it is put together

A **pane** (spec 3.3) is a macOS space labelled `wm.<workspace>.<rank>`, e.g.
`wm.q.1`. Labels rather than mission-control indices, because indices shift
whenever a space is created or moved.

**Rank** is the *effective* priority rank: attached displays sorted by stored
priority and then densely renumbered `1..R`. Unplugging the stored-primary monitor
promotes the stored-secondary to rank 1, and it inherits the `.1` panes. This is
what makes "the primary pane" (C5, C7) and single-display degradation (C10)
work without special cases.

Spaces are **never destroyed**. When a display goes away its panes are parked and
their windows evacuated into the lowest-priority surviving pane; when it comes
back the parked panes are moved to it. That is why replugging restores full
behaviour with no manual step (item 25).

yabai's `DISPLAY_SEL` does not accept a UUID, so display UUIDs are the stored
identity — as spec 3.2 requires — and are resolved to arrangement indices at call
time.

### Space labels do not survive a yabai restart

yabai keeps space labels in memory only. Restart yabai and every label is gone,
which would take the whole pane model with it — after a restart or a reboot,
`wm.q.1` would name nothing and windows would appear to have changed workspace.

macOS space UUIDs *are* stable across yabai restarts and reboots, so the
space-UUID → pane-label map is kept in `panes` (see below) and re-applied by
`wm_relabel_panes`, which runs at the top of `wm-adapt` and `wm-reconcile`.
`yabairc.sh` calls `wm-adapt`, so a yabai restart restores the labels on its own.
This is why yabai restarting is not a reason to re-run `wm-reconcile`.

### Rotation moves windows between panes, not panes between displays

`wm-rotate-displays` (C12) never touches the pane↔display mapping. Pane
`wm.<ws>.<rank>` stays on the display of that rank, and rotating means moving the
*windows* of `wm.<ws>.<rank>` into the pane of the next display in the cycle. That
is what keeps priority order — and therefore C5 and C7 placement — unchanged by a
rotation (item 43), and it is why panes of other workspaces are never addressed
(item 42).

Two orders are in play here and they are not the same one:

* **priority order** (`wm_live_ranked`) decides *which* displays take part —
  sticky ones sit the rotation out — and names their panes;
* **reading order**, derived from the display frames in `wm_query_displays`,
  decides the *cycle*: rows by overlapping vertical extent, rows top to bottom,
  left to right within a row.

Reading order is never stored, for the same reason adjacency is never stored:
rearranging monitors in System Settings has to change the cycle with no
configuration change (item 45). `wm_live_ranked` is the tempting helper here and
is the wrong one for the cycle — it hands back priority order, which on a machine
whose primary monitor is not the leftmost gives a different, and wrong, rotation.

Every participating display's window set is captured *before* any window moves.
Moving display by display without that snapshot walks straight into the trap spec
9.10 names: windows moved onto a display get picked up again and carried on to the
next one, so a rotation over three displays would pile everything onto the last.

Floating windows need no special case. A pane's `windows` list is its whole
membership, floating windows included, and on a cross-display `window --space`
yabai re-frames the window itself: tiled windows are re-tiled, floating ones are
moved relative to the new display origin and clamped if the destination is
smaller. All three were measured on yabai 7.1.25 rather than assumed, because the
opposite — `--space` moving a window's space without moving its frame — would have
left floating windows drawn over the monitor they came from.

### Files

| Path | Role |
| --- | --- |
| `yabai-module.nix` | options, script packaging, and the generated `skhdrc` |
| `yabairc.sh` | yabai settings and signals; symlinked out of store, so edits are live |
| `wm/wm-lib.sh` | state, ranking, panes, and the C2/C6/C10 core |
| `wm/wm-*.sh` | one script per capability |

`skhdrc` is generated from `yabai-module.nix`, so **changing a binding needs
`home-manager switch`**. `yabairc.sh` is not.

### Commands

| Command | Purpose |
| --- | --- |
| `wm-reconcile [--dry-run]` | create, label and place the 18×R panes. Idempotent. |
| `wm-display-priority` | say which monitor is primary (C11). Interactive, with a cue on every screen. |
| `wm-display-priority --set A C B` | same, non-interactive, by cue letter / arrangement index / UUID. |
| `wm-display-priority --list` | current assignment as text. |
| `wm-adapt` | re-home panes after a display change. Runs automatically; rarely needed by hand. |
| `wm-status` | active workspace, effective ranks, sticky set, visible pane per display. |

The rest (`wm-workspace-focus`, `wm-focus-dir`, `wm-move-dir`, `wm-window-send`,
`wm-sticky-toggle`, `wm-rotate-displays`, `wm-place-new-window`) are what the key
bindings and yabai signals call.

### Mutable state

`$XDG_STATE_HOME/yabai-wm/`, defaulting to `~/.local/state/yabai-wm/`:

| File | Contents |
| --- | --- |
| `display-priority` | one display UUID per line; line *n* is priority rank *n*. Detached displays are kept, so priorities survive replugging in a different order. |
| `panes` | `<space-uuid>\t<pane-label>`. Restores labels that yabai forgot on restart — see above. |
| `active-workspace` | the workspace most recently switched to. |
| `sticky-displays` | UUIDs of displays currently exempt from workspace switching. |

Deliberately outside the Nix store and outside this repository: C11 requires the
priority tool to write only to mutable state and never to generated
configuration.

## Setup

Once per machine, after `home-manager switch`:

```sh
yabai --restart-service && skhd --restart-service

wm-display-priority     # declare which monitor is primary
wm-reconcile            # create the panes
```

`wm-reconcile` adopts existing unlabelled spaces before creating new ones, so a
machine that already has spaces does not end up with those *plus* 18×R more.
Expect it to take a while the first time: space creation is animated, and three
displays means 54 panes.

Run `wm-display-priority` again whenever a monitor the tool has not seen before is
attached — though nothing breaks if you do not. An unknown display is
automatically given the lowest unused priority and every binding keeps working.

## Conformance

The spec's section 8 is a 47-item checklist and is the acceptance test. Notes on the
items that depend on choices this implementation was free to make:

- **item 17** (all displays sticky) — the toggle is refused for the last live
  display, with a note on stderr and exit status 0.
- **item 19** (unplug the only live display) — `wm-adapt` runs from
  `display_removed` and releases the highest-priority sticky display.
- **items 20–22** (new window placement) — C7 is a SHOULD. `wm-place-new-window`
  delays and retries once, and leaves the window alone if it did not land on a
  pane of the active workspace. That is the fallback to native placement the spec
  asks for, and it is also what keeps windows opened onto a sticky display from
  being yanked away.
- **item 26** (rearranging monitors) — adjacency is never stored. `wm-focus-dir`
  and `wm-move-dir` fall back to `yabai -m display --focus|--display <direction>`,
  so yabai's own geometry resolution decides, in all four directions.
- **item 30** (priorities unchanged after restarting the window manager) — both
  the priorities *and* the pane identities are kept outside yabai, keyed on UUIDs
  that macOS keeps stable.
- **items 41–47** (rotation) — the cycle is recomputed from the display frames on
  every press, so item 45 needs no step beyond rearranging the monitors. Item 46
  falls out of `wm_live_ranked`: fewer than two live displays and the script
  returns 0 having done nothing. If a participating display's pane does not exist
  yet — `wm-reconcile` never run — nothing is moved and the script says so, rather
  than rotating part of the way round.
- **item 33** (kill the priority tool mid-assignment) — two layers: a
  `trap … EXIT INT TERM HUP`, plus a watchdog inside each cue process that exits
  once the tool's pid disappears. The second covers `SIGKILL`, which no trap can.

### Verified on a single display

`wm-reconcile` (adoption of existing spaces, idempotence), label restoration
across a yabai restart, C2 paired switching with exactly one focused display,
C5 send and send-and-follow, C6 item 18 (the last live display refuses to become
sticky, exit status 0), C8 pane-confined zoom with native fullscreen staying off,
C9 float, and C11 `--set` byte-identical on a rerun.

Also the one-display clause of C12 **item 46**: `o` with a single display attached
changes no space and exits 0.

### Verified on two displays (C12)

Built-in plus one external, side by side, with the external as the primary — a
useful arrangement to test on, because there priority order is the *reverse* of
reading order.

- **item 41** — one window per display, `o` exchanges them, `o` again restores the
  original arrangement. Both tiled and floating windows were checked, and the
  frames confirm the windows are genuinely re-framed onto the other monitor rather
  than left drawn over the one they came from.
- **item 42** — a rotation changes the panes of the active workspace and nothing
  else; the full pane dump differs in exactly those two lines. Switching to
  another workspace and back leaves it as it was.
- **item 43** — after rotating, a send to an empty workspace still lands on the
  primary display, and a new window still takes the highest-priority empty pane.
  The rank↔display mapping is identical before and after.
- **item 46**, sticky half — with the built-in sticky only one live display
  remains, and `o` moves nothing and exits 0 with nothing on stderr.
- **item 47** — focused window, `o`, then synthesised keystrokes: the text arrived
  in that window on its new display.

Not verified, and honestly cannot be with two monitors: **items 44 and 45**, which
need three displays to tell a rotation from a swap and to make a rearrangement
change the cycle, and the clause of **item 46** where live displays rotate among
themselves *around* a sticky one, which also needs a third display. The reading
order those items exercise was checked against synthetic display frames — the
three arrangements the spec draws, plus a stagger where a short display sits
beside a tall one — but that exercises the geometry rule, not yabai, so it is not
a pass on either item.

Everything else that genuinely needs two or more monitors — C2 pairing across
displays, C3/C4 crossing bezels, C5 primary→secondary→primary, stickiness items
14–17 and 19, degradation items 23–25, rearrangement item 26, and the C11 cues —
still needs a pass of its own.

Known gap on the sibling implementation: `modules/linux/compositor/hyprland`
does not yet conform on its own terms — it enters the mode with `CONTROL+A`,
resizes with `SUPER` instead of `alt`, and defines only 13 of the 18 workspace
keys. Item 38 compares the two tables; the mismatches are on the Hyprland side.

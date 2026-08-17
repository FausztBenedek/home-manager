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
| Fullscreen toggle | `f` / `ctrl-f` | same | `yabai -m window --toggle zoom-fullscreen` |
| Float toggle | `z` / `ctrl-z` | same | `yabai -m window --toggle float` |
| Toggle split direction | `i` / `ctrl-i` | same | `yabai -m window --toggle split` |
| Balance panes | `shift-7` | `shift - 0x1A` | `yabai -m space --balance` |
| Resize | `alt-h/j/k/l` | same | `yabai -m window --resize …` |
| Directional focus, globally | `ctrl-cmd-h/j/k/l` | same | `wm-focus-dir …` — the one addition section 5 permits |

Bare `9`, `f`, `z`, `i` and `shift-7` are the stay-in-mode halves of pairs whose
`ctrl` variant section 5 lists; C1 requires both to exist.

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
`wm-sticky-toggle`, `wm-place-new-window`) are what the key bindings and yabai
signals call.

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

The spec's section 8 is a 40-item checklist and is the acceptance test. Notes on the
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
- **item 33** (kill the priority tool mid-assignment) — two layers: a
  `trap … EXIT INT TERM HUP`, plus a watchdog inside each cue process that exits
  once the tool's pid disappears. The second covers `SIGKILL`, which no trap can.

### Verified on a single display

`wm-reconcile` (adoption of existing spaces, idempotence), label restoration
across a yabai restart, C2 paired switching with exactly one focused display,
C5 send and send-and-follow, C6 item 18 (the last live display refuses to become
sticky, exit status 0), C8 pane-confined zoom with native fullscreen staying off,
C9 float, and C11 `--set` byte-identical on a rerun.

Everything that genuinely needs two or more monitors — C2 pairing across displays,
C3/C4 crossing bezels, C5 primary→secondary→primary, stickiness items 14–17 and
19, degradation items 23–25, rearrangement item 26, and the C11 cues — still needs
a pass with the externals attached.

Known gap on the sibling implementation: `modules/linux/compositor/hyprland`
does not yet conform on its own terms — it enters the mode with `CONTROL+A`,
resizes with `SUPER` instead of `alt`, and defines only 13 of the 18 workspace
keys. Item 38 compares the two tables; the mismatches are on the Hyprland side.

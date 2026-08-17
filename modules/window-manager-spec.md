# Window Manager Specification

A portable specification for a keyboard-driven, modal tiling window manager
workflow. The same workflow is to be implemented on **yabai + skhd** (macOS),
**Hyprland** (Linux), and **GlazeWM** (Windows), so that muscle memory transfers
unchanged between machines.

This document specifies **capabilities, behaviour, and key bindings**. All three
are normative: the bindings in §5 are as binding as the behaviour in §4, because
transferable muscle memory is the entire point. Implementation *mechanism* —
languages, scripts, config generators, storage formats — is left entirely to the
implementer.

Requirement levels follow RFC 2119: **MUST**, **SHOULD**, **MAY**.

---

## 1. Design goals

1. **Key→workspace invariance.** The same keypress reaches the same workspace on
   every machine, whatever number of displays happens to be attached. This is the
   single guarantee the whole workflow rests on.
2. **Displays form one continuous canvas.** Directional movement flows across
   monitor boundaries as if the bezels were not there.
3. **Workspace switching is global.** One keypress re-targets every display at
   once, so the relationship between what is on one screen and what is on the
   others is stable and predictable.
4. **Graceful degradation.** Removing a monitor never breaks a binding. The
   layout collapses; the keymap does not change.

---

## 2. Terminology

| Term | Meaning |
| --- | --- |
| **Workspace** | One of 18 addressable slots. Spans *all* displays. |
| **Display position** | A logical slot a physical monitor occupies (`1`, `2`, `3`). |
| **Attached** | A display position is *attached* when a physical monitor is currently driving it. The spec is concerned only with **how many** positions are attached, never with how they are connected — dock, hub, direct cable, or otherwise. Terms like "docked" carry no meaning here. |
| **Pane** | The intersection of a workspace and a display position — the actual surface windows are tiled on. Workspace `d` on display position 2 is pane `d.2`. |
| **Active workspace** | The workspace most recently switched to. Global, single-valued. |
| **Sticky display** | A display position temporarily exempt from workspace switching. At least one attached display MUST always be non-sticky — see the C6 invariant. |
| **Live display** | An attached display that is *not* sticky, and therefore follows workspace switches. There is always at least one. |
| **Spatial adjacency** | Which display lies immediately left, right, above, or below another, derived from actual monitor geometry. Governs directional movement. |
| **Priority order** | Preference ranking (primary → secondary → tertiary). Governs placement. |

**Spatial adjacency and priority order are independent and are established
differently.** Adjacency is *derived* from how the monitors are physically
arranged — the operating system already knows this, and the spec never asks the
user to restate it. Priority order is *declared* by the deployment and cannot be
inferred from geometry. The primary display may sit anywhere in the arrangement:
leftmost, in the middle, or below the others.

Monitors may be arranged in any direction. A stacked arrangement — one monitor
above another — is as valid as a side-by-side one, and mixed arrangements (two
side by side with a third below) are valid too. Nothing in this spec assumes a
horizontal row.

---

## 3. Model

### 3.1 Workspaces

There are exactly **18 workspaces**, identified by these stable keys:

```
q w e r t s d g y x c v 0 1 2 3 4 5
```

Workspace identifiers are **opaque**. They carry no semantics, imply no ordering,
and MUST NOT be reassigned between machines. An implementation MAY attach
human-readable labels where the platform requires them (macOS spaces need labels
to survive reindexing), but such labels are an implementation detail and MUST NOT
affect behaviour.

Workspaces MUST be addressable directly — every workspace is one keypress away
from every other. Cycling (next/previous) is not part of the model.

### 3.2 Display positions

An implementation is configured with a list of display positions. For each
position the deployment declares exactly one thing:

- its **priority rank** — primary, secondary, tertiary

Priority is assigned through the tool required by **C11**, not by hand-editing
identifiers.

Spatial adjacency is **not** declared. It MUST be derived from the monitors'
actual geometry as reported by the platform, so that rearranging monitors in the
OS display settings takes effect without touching any configuration.

The implementation MUST map these logical positions onto whatever identifiers its
platform provides, and MUST prefer stable identifiers over volatile ones:

| Platform | Use | Avoid |
| --- | --- | --- |
| yabai | display UUID | display index (arrangement-order, shifts on replug) |
| Hyprland | connector name (`eDP-1`, `DP-1`) | monitor index |
| GlazeWM | monitor device name | enumeration order |

**Reference deployment** (three displays):

| Position | Priority | Hardware |
| --- | --- | --- |
| 1 | primary | centre external monitor |
| 2 | secondary | second external monitor |
| 3 | tertiary | laptop panel |

Note that priority does not track position: the primary sits physically in the
middle, and the laptop panel is commonly *below* the externals rather than beside
them. Both facts are irrelevant to configuration — the deployment declares only
the priority column above, and adjacency follows from wherever the monitors
actually are.

#### Resolving adjacency

Given a direction and a source display, the **adjacent display** is determined
from monitor geometry as follows:

1. Consider only displays lying in the given direction from the source.
2. Of those, consider only displays whose extent **overlaps** the source's extent
   on the perpendicular axis — for a horizontal move, those sharing some range of
   vertical space; for a vertical move, some range of horizontal space.
3. Of those, choose the **nearest**.
4. If no display qualifies, there is no adjacent display in that direction.

Purely diagonal neighbours are therefore not reachable in one step, which is
intended: a display sitting only to the upper-right is neither "right" nor "up".

All three target platforms already perform this resolution natively — yabai via
`display --focus north|south|east|west`, Hyprland via `movefocus`, GlazeWM via
`focus --direction`. Implementations SHOULD use the platform's own resolution
rather than recomputing it, and MAY expose an explicit adjacency override for
deployments where the platform's geometry is wrong or unhelpful.

### 3.3 Panes

Every workspace has one pane per display position. With 18 workspaces and *N*
displays there are 18 × *N* panes.

On platforms where panes are heavyweight and must be pre-allocated (macOS
spaces), the implementation MUST provide a reconcile operation that creates,
labels, and assigns panes to bring reality in line with this model. That
operation:

- MUST be idempotent — safe to run at any time
- MUST be runnable on demand, as monitors are connected or disconnected
- SHOULD NOT be required to run automatically

> **Scale note.** 18 workspaces × 3 displays = 54 macOS spaces. Space creation is
> slow and animated; the reconcile operation should expect to need pacing between
> operations, and must label panes before moving them, because indices shift
> during the moves.

---

## 4. Capabilities

### C1 — Modal layer

All window-management bindings MUST live behind a mode, so they do not consume
keys during normal application use.

- Entering the mode MUST NOT alter window state.
- The mode MUST be exitable by a dedicated key, and MAY be exitable by the entry
  key.
- Every command MUST have a variant that performs the action and exits the mode
  in one keypress. (The existing configurations use a `ctrl` prefix for this.)

The mode entry key MUST be configurable — see §6.

### C2 — Workspace switching (paired)

Activating workspace `W`:

- MUST set `W` as the active workspace.
- MUST make every **non-sticky** display position show its pane of `W`,
  simultaneously.
- MUST NOT alter sticky display positions.
- MUST leave keyboard focus on exactly one display. Focus SHOULD land on the
  primary display when it is non-sticky; otherwise the choice is left to the
  implementation.
- MUST always have at least one display to act on. By the invariant in C6, at
  least one attached display is always non-sticky, so a workspace switch can never
  be a complete no-op.

This is native in none of the three target window managers and will require a
script or IPC wrapper in each.

### C3 — Directional focus

Move focus one step in a direction (left / down / up / right).

- MUST move to the adjacent window within the current display if one exists.
- MUST otherwise move focus to the **spatially adjacent** display in that
  direction, resolved per §3.2, focusing a window in whatever pane that display
  currently shows. This applies equally to all four directions: where monitors
  are stacked, up and down cross displays exactly as left and right do.
- MUST NOT wrap around the outermost edges. An implementation MAY offer wrapping
  as an option, off by default.
- If the adjacent display shows an empty pane, focus MUST still move to that
  display.

Hyprland (`movefocus`) and GlazeWM (`focus --direction`) cross monitor boundaries
natively. yabai does not, and requires an explicit fallback to a display-level
focus command.

### C4 — Directional move

Move the focused window one step in a direction, carrying focus with it.

- Within a pane, this is purely directional — it rearranges the tiling and MUST
  NOT consult priority order.
- At a pane's edge, the window MUST move into the **spatially adjacent** display
  in that direction, resolved per §3.2, entering whatever pane that display
  currently shows — in any of the four directions.

> **Interaction with stickiness.** If the adjacent display is sticky it is showing
> a pane of some *other* workspace. Moving a window onto it therefore moves that
> window to a different workspace. This is intended: the window goes where the
> user can see it. Implementations MUST allow it and MUST NOT special-case it.

As with C3, yabai needs a fallback to a display-level move; the other two cross
bezels natively.

### C5 — Send window to workspace

Send the focused window to workspace `W`. Unlike C4, this is **not** directional —
the destination pane is chosen by priority.

Destination selection:

1. The **first pane of `W`, in priority order, that contains no windows**.
2. If every pane of `W` is occupied, the **primary** pane of `W`.

Two variants MUST be provided:

- **Send** — the window moves; focus and the active workspace do not change.
- **Send and follow** — the window moves, then workspace `W` is activated per C2.

### C6 — Display stickiness

A per-display toggle that exempts a display from C2.

- Toggling MUST apply to the display that currently has focus.
- Stickiness MUST be independently settable on each display, subject to the
  invariant below.
- While sticky, a display MUST ignore workspace switches and continue showing its
  current pane.
- On **un-sticking**, the display MUST immediately snap to its pane of the active
  workspace.
- All other operations — directional focus, directional move, send-to-workspace —
  MUST continue to work normally on a sticky display.

#### Invariant: at least one display is always live

**At no point may every attached display be sticky.** At least one attached
display MUST always remain live, so that workspace switching always has a visible
effect. This state MUST be unreachable — both by pressing the toggle and as a
consequence of monitors being connected or disconnected.

**How the invariant is upheld is left to the implementation.** Refusing the
toggle, releasing some other display, or any other means are all acceptable, as
are the choice of which display to release and whether the user is told anything.
The only requirements are that a live display always exists and that attempting to
violate the invariant MUST NOT produce an error.

This subsumes the single-display case: with one display attached it is the last
live one, so it cannot become sticky.

Because the invariant holds, C2 always has at least one display to act on, and no
workspace switch is ever a complete no-op.

### C7 — New window placement

When an application opens a new window, the implementation SHOULD place it using
the same rule as C5: first unoccupied pane of the active workspace in priority
order, otherwise the primary pane.

This is **SHOULD**, not MUST. No target window manager expresses conditional
placement declaratively; all three require an event hook that inspects occupancy
after the window appears:

| Platform | Mechanism | Notes |
| --- | --- | --- |
| yabai | `signal --add event=window_created` | May fire before placement settles; expect to need a retry or short delay. |
| Hyprland | `openwindow` event on the `socket2` IPC | `windowrulev2` alone is insufficient — it cannot branch on occupancy. |
| GlazeWM | IPC / WebSocket API | Weakest support of the three; static window rules cannot express this. |

Where the hook proves unreliable, the implementation MUST fall back to the
platform's native placement rather than leaving windows in an indeterminate
state.

### C8 — Fullscreen toggle

Toggle the focused window to fill its pane. MUST be confined to the pane — it
MUST NOT span displays, and MUST NOT use a platform's native fullscreen-space
mechanism where one exists (notably macOS), because those create surfaces outside
this model.

### C9 — Float toggle

Toggle the focused window between tiled and floating. A floating window is exempt
from tiling but MUST remain subject to C2, C4, and C5.

### C10 — Single-display degradation

When exactly one display is attached:

- All 18 workspaces MUST remain addressable by their normal keys.
- Each workspace collapses to a single pane. Windows that belonged to secondary
  or tertiary panes MUST appear in that pane and be tiled normally by the window
  manager.
- C2 reduces to an ordinary workspace switch.
- C3 and C4 reduce to within-display movement.
- C6 becomes a no-op.

Reattaching a display MUST restore full behaviour. Implementations are **not**
required to restore which pane a given window originally occupied.

### C11 — Display priority assignment

Priority order (§3.2) is the one aspect of display configuration that cannot be
derived and must be stated by the user. An implementation MUST therefore provide
a tool that assigns priority ranks to the attached displays, so that plugging in
an unfamiliar monitor does not require hand-editing identifiers.

**Behaviour**

- The tool MUST be runnable on demand and MUST be idempotent — running it when
  nothing has changed MUST leave the configuration unchanged.
- It MUST identify displays by the stable identifiers of §3.2, never by
  enumeration order.
- Assignments MUST persist across disconnection, reconnection, and restart of the
  window manager or the machine.
- It MUST provide a non-interactive mode that takes assignments as arguments, so
  the workflow can be scripted and reproduced on a new machine.
- Changing priority SHOULD trigger, or offer to trigger, the reconcile operation
  of §3.3, because which pane belongs to which display depends on priority.

**Visual identification**

While assignment is in progress, the tool SHOULD display a distinct, unambiguous
identifier **simultaneously on every attached display**, so the user can see which
physical screen is which without moving windows around or guessing.

- The identifier SHOULD be large and legible from normal seating distance, and
  MUST distinguish displays unambiguously — a numeral or letter, optionally
  reinforced by colour. Colour alone MUST NOT be the only distinguishing feature.
- The cue SHOULD indicate each display's *current* priority alongside its
  identifier, so the user can see what they are changing.
- After assignment, the tool SHOULD redisplay the cues reflecting the new
  priorities, as confirmation.
- Cues MUST be dismissed when the tool exits, including when it exits abnormally.

The most portable mechanism requires no new dependency: an implementation already
has, by C4 and C5, the ability to place a window on a chosen display. Parking a
window that renders a large identifier on each display satisfies this requirement
using capabilities the spec already mandates. Platform-native alternatives —
Wayland layer-shell overlays, per-output notifications, or an OS "identify
displays" feature — MAY be used where available.

Visual identification is a **SHOULD**, not a MUST: a conforming implementation on
a platform with no workable overlay mechanism may fall back to naming displays
textually by identifier and resolution. The non-interactive mode remains
mandatory in that case.

**Unknown displays**

A display attached with no stored assignment MUST NOT break the workflow. It MUST
receive the lowest unused priority automatically, and every capability MUST remain
functional until the user chooses to run the tool.

**Storage**

Assignments MUST be written to mutable state that is separate from any generated
or read-only configuration. Where the window manager configuration is produced by
a build system that renders it immutable — a Nix store path, for instance — the
tool MUST NOT attempt to modify that configuration, and the implementation MUST
read priority from the mutable state at runtime.

### C12 — Rotate display contents

Move the windows of the active workspace from each live display to the next, so
that a two-display arrangement exchanges its two screens and a three-display
arrangement rotates through all three.

- The operation MUST act only on the **active workspace**. Panes of other
  workspaces MUST NOT be disturbed.
- It MUST move **windows between displays**. It MUST NOT remap which pane belongs
  to which display, and MUST NOT alter priority order. After the operation the
  primary display is still the primary display, and C5 and C7 still place windows
  exactly as they did before.
- Every window on a participating display MUST travel, floating windows included
  — a floating window is subject to C12 as it is to C2, C4, and C5.
- Keyboard focus MUST stay on the same **window**, which is now on a different
  display. Focus does not stay behind on the physical screen.
- Repeating the operation *N* times, where *N* is the number of participating
  displays, MUST restore the original arrangement.

#### Which displays participate

Only **live** displays participate. A sticky display is showing a pane of some
other workspace by the user's explicit request (C6), and rotating that pane out
would defeat the purpose of the toggle; sticky displays MUST therefore be skipped,
and the cycle MUST close over the live displays alone.

- With fewer than two live displays the operation MUST be a no-op and MUST NOT
  error. This covers the single-display case of C10.

#### Cycle order

The participating displays MUST be ordered by **reading order**, derived from
monitor geometry as reported by the platform:

1. Group displays into rows: two displays are in the same row when their vertical
   extents overlap.
2. Order rows from top to bottom.
3. Order the displays within a row from left to right.

Contents move from each display to the next in that sequence, and from the last
display back to the first.

Reading order is *derived*, never declared — like the adjacency of §3.2 and unlike
the priority order of §3.2. Rearranging monitors in the OS display settings MUST
change the cycle with no configuration change. Priority order MUST NOT influence
it.

```
[A][B][C]   →  A B C   →  A→B, B→C, C→A

[A][B]      →  A B C   →  A→B (right), B→C (down), C→A (wrap)
   [C]

[A]
[B]         →  A B C   →  contents move down, bottom wraps to top
[C]
```

### Optional capabilities

These MAY be implemented and their precise behaviour MAY differ between platforms.
They are outside the portable core because at least one target cannot express
them faithfully.

Where an implementation does provide one, it MUST use the reserved binding listed
in §5 — an optional *capability* does not imply an optional *key*.

- **Resize** — adjust the focused window's dimensions. All three support this
  with incompatible syntax and step semantics.
- **Toggle split direction** — flip the split axis of the focused container.
  Native to yabai and Hyprland's dwindle layout; GlazeWM has no direct equivalent.
- **Balance panes** — equalise sibling window sizes within a pane. Native to
  yabai; approximated or absent elsewhere.
- **Swap vs. warp** — yabai distinguishes exchanging two windows from re-parenting
  one into another's position; Hyprland partially does; GlazeWM has only a single
  move. C4 specifies the portable behaviour; any finer distinction is an
  extension.

---

## 5. Key mapping

**This section is normative.** The bindings below are not a suggestion — they are
the workflow. Design goal 1 is that the same keypress does the same thing on every
machine, and a conforming implementation MUST bind exactly these keys to exactly
these actions.

An implementation that provides every capability in §4 but binds them differently
does **not** conform.

| Action | Binding | Capability |
| --- | --- | --- |
| Enter mode (host) | `ctrl-m` | C1 |
| Enter mode (guest — see §6) | `ctrl-n` | C1 |
| Exit mode | `escape`, or the entry key | C1 |
| Directional focus | `h` `j` `k` `l` | C3 |
| Directional move | `shift-h/j/k/l` | C4 |
| Switch to workspace | *workspace key* | C2 |
| Switch and exit mode | `ctrl-`*key* | C2 |
| Send window to workspace | `shift-`*key* | C5 |
| Send and follow, exit mode | `ctrl-shift-`*key* | C5 |
| Toggle display stickiness | `ctrl-9` | C6 |
| Rotate display contents | `o` | C12 |
| Fullscreen toggle | `f` | C8 |
| Float toggle | `z` | C9 |

Workspace keys, in the roles above: `q w e r t s d g y x c v 0 1 2 3 4 5`.

Directional keys outside the mode MAY additionally be bound globally; the current
macOS configuration uses `ctrl-cmd-hjkl`. This is the one addition permitted, and
it MUST NOT replace the in-mode bindings.

### Notation versus deviation

Platforms spell keys differently — skhd uses hex keycodes such as `0x2A`, Hyprland
uses names such as `SUPER`, GlazeWM uses its own syntax. Expressing `shift-l` in a
platform's own notation is **not** a deviation; it is the same binding written
differently. What matters is the key the user physically presses.

### Permitted deviation

A binding MAY differ from this table **only** where the platform or operating
system reserves that key combination and the reservation cannot be disabled. In
that case the implementation MUST:

1. document the substitution prominently, next to the configuration;
2. change as little as possible — substitute the single conflicting binding, never
   reorganise the scheme around it;
3. keep every other binding in the table intact.

Convenience, platform convention, and implementer preference are **not** grounds
for deviation.

### Reserved bindings

These keys correspond to optional capabilities. An implementation that provides
the capability MUST use the binding shown; one that does not provide it MUST leave
the key unbound rather than reuse it for something else, so the key means the same
thing or nothing everywhere.

| Action | Binding |
| --- | --- |
| Toggle split direction | `i` |
| Balance panes | `shift-7` |
| Resize | `alt-h/j/k/l` |

---

## 6. Nested sessions

The workflow is expected to run inside virtual machines and remote desktop
sessions whose guest OS runs its own window manager.

- The guest implementation MUST behave identically to the host in every respect
  described here.
- The **only** permitted difference is the mode entry key: the guest uses
  `ctrl-n` rather than `ctrl-m`, so that host and guest layers do not collide.
  Both are normative per §5; this is the single sanctioned divergence between a
  host and a guest keymap, and no other binding may differ.
- The host MUST NOT intercept the guest's entry key while a guest window has
  focus. How this is arranged — keyboard layer switching, application-scoped
  binding exclusions, or window-manager rules — is the implementer's concern and
  is outside this specification.

---

## 7. Out of scope

The following are deliberately excluded. Implementations may do as they please.

- Application launching, menus, and window switchers
- Visual indication of the active mode (border colours, status bars). This
  exclusion does **not** cover the display-identification cues of C11, which are
  specified.
- A "disabled" mode that zeroes gaps and suspends bindings
- Gap, padding, and border dimensions
- macOS native fullscreen spaces
- Remote-desktop client integration and keyboard layer switching beyond §6
- Restoring which pane a window occupied across a disconnect/reconnect cycle

---

## 8. Conformance checklist

Each item is a concrete procedure. An implementation conforms when all MUST items
pass. Run with at least two displays attached unless stated otherwise.

### Workspace addressing

1. From workspace `q`, press each of the 18 workspace keys in turn. Each MUST
   land on a distinct workspace, and repeating the sequence MUST land on the same
   workspaces in the same order.
2. Disconnect all but one display, repeat step 1. All 18 MUST still be reachable.

### Paired switching (C2)

3. Place a distinguishable window in pane `d.1` and another in `d.2`. Switch to
   `q`, then back to `d`. Both windows MUST reappear on their original displays
   simultaneously.
4. After any switch, exactly one display MUST have keyboard focus.

### Directional movement (C3, C4)

5. Focus the window nearest an edge of one display that has another display
   beyond it. Press the focus key for that direction. Focus MUST move to that
   display.
6. Repeat with the adjacent display's pane empty. Focus MUST still move there.
7. Press the focus key for a direction with **no** display beyond it. Nothing MUST
   happen — no wrap.
8. **Repeat 5–7 for every direction the arrangement provides.** If any two
   displays are stacked vertically, up and down MUST cross between them exactly
   as left and right do between side-by-side displays. Then repeat the whole set
   with the move keys — the window MUST travel with focus in every case.
9. With two windows side by side in one pane, press move-right on the left one.
   They MUST exchange positions without leaving the pane.

### Send to workspace (C5)

10. Ensure every pane of workspace `x` is empty. Send a window to `x`. It MUST
    land in the primary pane.
11. Send a second window to `x`. It MUST land in the secondary pane.
12. Send a third. It MUST land in the primary pane.
13. Verify send does not move focus, and send-and-follow does.

### Stickiness (C6)

14. Focus the secondary display and toggle stickiness. Switch workspaces several
    times. The primary MUST follow; the secondary MUST NOT change.
15. While the secondary is sticky, send a window to another workspace and use
    directional focus onto the sticky display. Both MUST work normally.
16. Toggle stickiness off. The secondary MUST immediately show its pane of the
    active workspace.
17. **Attempt to make every display sticky.** Stick all but one, then focus the
    remaining live display and toggle. Afterwards at least one display MUST still
    be live, and no error MUST occur. Switch workspaces to confirm something still
    follows. *Which* display is live, and whether the toggle was refused or another
    display released, is the implementation's choice and is not under test.
18. With one display attached, toggle stickiness. It MUST remain live and MUST NOT
    error.
19. **Disconnect the only live display** while others remain sticky. Without any
    user action, at least one attached display MUST become live and follow
    workspace switches. Which one is not under test.

### Placement (C7)

20. With the active workspace empty, open a window. It SHOULD appear on the
    primary display.
21. Open a second. It SHOULD appear on the secondary display.
22. Open a third. It SHOULD appear on the primary display.

### Degradation (C10)

23. With windows spread across two displays, disconnect the secondary. Its
    windows MUST appear on the remaining display, tiled.
24. Every binding from §5 MUST still function.
25. Reconnect. Full two-display behaviour MUST resume, with or without running a
    reconcile step.

### Rearrangement (§3.2)

26. In the OS display settings, move a monitor from beside another to above it.
    Without editing any configuration, up and down MUST now cross between them,
    and left and right MUST no longer do so. Priority order MUST be unaffected —
    the primary display MUST still receive windows per C5 and C7.

### Display priority assignment (C11)

27. Run the assignment tool. Every attached display SHOULD show a distinct,
    legible identifier at the same time, each indicating its current priority.
28. Reassign priority so a *different* physical monitor becomes primary. Open a
    new window and send a window to an empty workspace — both MUST now target the
    newly designated primary, per C7 and C5.
29. Run the tool again changing nothing. The stored configuration MUST be
    byte-identical.
30. Disconnect every display, reconnect them in a different order, and restart the
    window manager. Priorities MUST be unchanged.
31. Attach a monitor the tool has never seen. It MUST receive the lowest unused
    priority, every binding MUST keep working, and no manual step MUST be required
    to reach that state.
32. Invoke the tool's non-interactive mode with explicit assignments. The result
    MUST match what the interactive path produces.
33. Terminate the tool abnormally mid-assignment. No identification cue MUST
    remain on screen.
34. Where configuration is generated into read-only storage, confirm the tool
    writes only to mutable state and that the generated configuration is untouched.

### Key mapping (§5)

35. Every binding in the §5 table MUST be present and MUST invoke the stated
    capability. Check each row individually — this is the conformance test the
    whole workflow depends on.
36. No binding in the §5 table MUST be absent, remapped, or bound to a different
    action.
37. Every reserved binding whose optional capability is **not** implemented MUST
    be unbound — pressing it MUST do nothing rather than trigger something else.
38. Compare the §5 table against the same table as implemented on another
    platform. Every row MUST match. Any difference MUST correspond to a documented
    platform reservation per §5, and MUST be the minimum substitution.

### Rotate display contents (C12)

> Numbered from 41 although the section sits here, so that the numbering of items
> 1–40 stays stable for anything that already cites them. Checklist numbers are
> append-only.

41. With two displays, place a distinguishable window on each and press `o`. The
    two MUST exchange displays. Press `o` again — the original arrangement MUST
    return.
42. Switch to another workspace and back. That workspace MUST be unaffected by
    step 41.
43. After step 41, send a window to an empty workspace and open a new window.
    Both MUST still target the same physical display as before the rotation —
    priority MUST be unchanged.
44. With three displays, note the reading order of the arrangement, then press `o`
    three times. Contents MUST advance one position each press and MUST return to
    the start on the third.
45. Rearrange the monitors in the OS display settings so the reading order
    differs, and repeat step 44 without editing any configuration. The cycle MUST
    follow the new arrangement.
46. Make one display sticky and press `o`. The sticky display's contents MUST NOT
    move; the live displays MUST rotate among themselves. With only one live
    display, and again with only one display attached, `o` MUST do nothing and
    MUST NOT error.
47. Focus a window, press `o`, and type. Input MUST go to the same window on its
    new display.

### Nested sessions (§6)

39. Inside a guest session, the guest entry key MUST open the guest's mode and the
    host MUST NOT react.
40. Every check above MUST pass inside the guest.

---

## 9. Assumptions and open questions

Recorded so the implementer knows which decisions were specified and which were
inferred.

**Assumed, not confirmed:**

1. **C7 shares C5's rule.** New window placement was specified as
   primary-then-secondary; it is assumed to follow the same priority-order rule as
   send-to-workspace, including the "primary again when all occupied" fallback.
2. **Multiple sticky displays are permitted**, up to the C6 invariant — any number
   may be sticky provided one remains live.
3. **The C6 invariant is a requirement on outcomes, not on mechanism.** That a
   live display always exists is specified; how an implementation guarantees it —
   refusing the toggle, releasing another display, which one it picks, whether it
   tells the user — is deliberately unspecified.
4. **No wrapping** at the outermost display edges.
5. **C12 skips sticky displays.** Nothing in C6 required this — a sticky display
   could equally have participated. Skipping was chosen because a sticky display
   is deliberately showing another workspace's pane, and rotating that pane away
   would undo the toggle the user just pressed.
6. **C12 keeps focus on the window, not the display.** The alternative — leaving
   focus on the physical screen, so a different window becomes focused — was
   considered and rejected as more surprising.

**Left to deployment configuration:**

7. Priority order only (§3.2). Nothing else about displays is configured —
   spatial adjacency is derived from platform geometry, in all four directions,
   so monitor arrangements including vertical stacking need no declaration and
   rearranging monitors requires no config change. The reading order of C12 is
   likewise derived, not configured.

**Known implementation risk:**

8. C2 is native in none of the three target window managers. Each will need a
   wrapper that issues per-display commands. On macOS the ordering matters —
   switching the focus-target display last is the simplest way to land focus
   correctly, since `space --focus` also moves focus.
9. C7 depends on event hooks with known timing sensitivity, worst on GlazeWM.
   The specified fallback to native placement is the intended escape hatch.
10. C12 is native in none of the three either, and a naive implementation that
    moves each display's windows to the next display in sequence will carry
    already-moved windows along with them. The window set of every participating
    display must be captured *before* any window moves.

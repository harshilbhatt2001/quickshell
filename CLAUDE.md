# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

VoidBar — a minimal Quickshell (QML) status bar for Hyprland. Deliberately anti-feature-creep: no theme switcher, no launcher, no settings app. Modules hide themselves entirely when they have nothing to say (no wifi icon when disconnected, no bluetooth icon when nothing is connected), and some modules only show on the focused monitor. Read the README for the full ethos before proposing new features — "more features" is usually the wrong direction here.

## Commands

Development happens inside a devenv shell (`devenv shell`), which provides `quickshell`, `qmlformat`, and `qmlls`, and regenerates `.qmlls.ini` with Nix-store import paths on entry.

- Run the bar: `quickshell -p .` (also available as the devenv process: `devenv up`)
- Format: `qmlformat -i <file>.qml` (config in `.qmlformat.ini`: tabs, 2-width indent, sorted imports, normalized attribute order)
- Lint/LSP: `qmllint <file>.qml` / `qmlls` — both read import paths from the generated `.qmlls.ini`

Note: running quickshell replaces `.qmlls.ini` with a symlink into its own VFS (`/run/user/<uid>/quickshell/vfs/...`). If `qmllint` stops resolving `Quickshell.*` imports, re-enter the devenv shell to regenerate it.

There are no tests. Verification is running the bar and looking at it.

## Architecture

Entry point is `shell.qml` → `Bar.qml`, which uses `Variants` over `Quickshell.screens` to create one `PanelWindow` per monitor. The window is a transparent full-width strip with a click-through `mask` limited to the three module regions: left (workspace selector), center (clock/mpris), right (network, bluetooth, battery). This left/center/right split is a design decision, not incidental layout.

Three layers:

- `Services/` — singletons (declared in `Services/qmldir`, each with `pragma Singleton`) that own all system state: `BatteryManager` (UPower), `NetworkManager`, `BluetoothManager`, `MprisManager`, `WorkspaceManager` (Hyprland), `NotificationManager`, `Time`, `CalendarManager` (Google Calendar via gcalcli: `agenda --tsv` to read, `add`/`edit`/`delete` to write; `editing` pins the island open and gives the bar keyboard focus), and `IpcManager` (a Quickshell `IpcHandler` on target `"root"`, e.g. `quickshell ipc call root openLogoutMenu`). Adding a service means adding the file *and* registering it in `qmldir`.
- `Bar/` — one module per file. Each wraps `Components/Container.qml` and binds service state to it. Modules receive the window's `HyprlandMonitor` via a required `monitor` property.
- `Components/Container.qml` — the shared module shell and the most load-bearing file in the repo. It implements the open/close (click-to-expand) behavior via `defaultItem`/`openedItem` components, the slide-off-screen hiding (`forceHidden`, width collapse, `calculatedTopMargin`), monitor exclusivity (`exclusiveToScreen`/`exclusiveMonitor` — module only visible on the focused monitor), hover handling, and all spring animations. New bar modules should build on it rather than reimplementing any of this.

Two ways a module drives its Container:

- *Static config* — set `defaultItem`/`openedItem`, `exclusiveToScreen`, and bind `forceHidden` to a service predicate (e.g. `!BluetoothManager.anyConnected`). This is all Network/Bluetooth/Battery do.
- *Temporary content swaps* (Time's notification toast and its hover "island", a `SwipeView` pager of mpris + `Bar/Calendar/CalendarPage`, paged with the horizontal wheel) — declare QML `states` whose `PropertyChanges` override the Container's `box*` sizing properties and whose `StateChangeScript` calls `root.stack.replace(<component>)`. The `stack` alias is the Container's internal `StackView`; a timer then flips the state flag back to return to `defaultItem`.

`Services/IpcManager` currently only emits a `logoutMenu` signal that nothing listens to — the in-bar logout menu was removed from `Bar/Time.qml` and a replacement is planned (see README).

Colors come from `Color.js` (Catppuccin Mocha palette), imported as `import "Color.js" as Colors` — no theming system, by design.

## Conventions

- QML files use tabs for indentation (per `.qmlformat.ini`); prettier (for non-QML files) uses 2 spaces.
- Attributes follow qmlformat's normalized order (properties sorted, ids first) — run `qmlformat` rather than ordering by hand.
- `.qmlls.ini` is generated and gitignored; never edit or commit it.

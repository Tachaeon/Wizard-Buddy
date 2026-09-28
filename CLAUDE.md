# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Wizard-Buddy is a PowerShell Windows Forms application that places an animated GIF companion in the system tray and optionally on the desktop. The right-click tray menu exposes admin utilities, one-click winget installs, registry tweaks, and buddy-swapping. The entire application is self-contained — all GIF and icon assets are Base64-encoded and embedded directly in the script, requiring no external files at runtime.

## Running

```powershell
# Requires PowerShell 7+
pwsh Start-WizardBuddy-v2.ps1

# Or as designed (via VBScript launcher, hidden window):
# CreateObject("Wscript.Shell").Run "powershell ... irm <url> | iex", 0, False
```

## File Map

| File | Purpose |
|------|---------|
| `Start-WizardBuddy-v3.ps1` | **Active version (v3.1)**. Same app as v2.1 plus the Scripts additions (SimpleHelp Spy Detection), the toggle-based Customize Windows menu and the OpsHub-style Speed Test (see "v3.1 additions") |
| `Start-WizardBuddy-v2.ps1` | Previous version (v2.1) |
| `Start-WizardBuddy.ps1` | Older version (v2.0) — uses deprecated `LoadWithPartialName`; kept for reference |
| `Base Wizard/Get-Wizard.ps1` | Minimal prototype — borderless form with a PictureBox and one GIF, no tray |
| `ShellContextMenu.ps1` | Standalone PowerShell shell context menu helper (COM-based); v2.1 uses an embedded C# version instead |
| `Get-Base64.ps1` | Utility — detects file type from Base64 byte signature and saves decoded files |

## Architecture (`Start-WizardBuddy-v2.ps1`)

### Embedded types
The script adds two C# types via `Add-Type -TypeDefinition`:
- **`User32`** — P/Invoke into `user32.dll` for `ReleaseCapture` and `SendMessage`, used to implement borderless-form dragging via the `WM_NCLBUTTONDOWN`/`HTCAPTION` trick on `PictureBox.MouseDown`
- **`ShellContextMenu`** — P/Invoke into `shell32.dll` and `user32.dll` for native Windows right-click context menus (`IShellFolder`, `IContextMenu`, `TrackPopupMenuEx`). Triggered when right-clicking an application submenu item.

### Form and rendering
- The desktop companion is a borderless, always-on-top, taskbar-hidden `Form` with `BackColor = DimGray` and `TransparencyKey = BackColor`, making everything except the GIF transparent.
- The GIF plays in a `PictureBox` (`SizeMode = StretchImage`). Loading images via `[System.Drawing.Image]::FromStream($memoryStream)` preserves GIF animation.
- MouseWheel resizes the form; Ctrl+MouseWheel adjusts opacity.
- Dragging is implemented by calling `User32.SendMessage(WM_NCLBUTTONDOWN, HTCAPTION)` on `PictureBox.MouseDown`, which tricks Windows into treating the click as a title-bar drag.

### Asset embedding
All buddy GIFs and menu icons are stored as Base64 strings in the script body. `Get-IconFromBase64` decodes them to `System.Drawing.Image`. To add a new buddy or icon, convert the file to Base64 and add the string as a variable.

### Tray and menus
- `NotifyIcon` (`$Systray_Tool_Icon`) lives in the system tray with a `ContextMenuStrip`.
- Left-click shows/positions the desktop form; right-click opens the menu.
- Menu items are built with `Add-MenuItem` (top-level, Base64 icon) and `Add-SubMenuItem` (nested; supports Base64 icon or auto-extracted icon from a `.exe` path via `ExtractAssociatedIcon`).
- When `Add-SubMenuItem` receives a `-FilePath`, it stores the path in the item's `.Tag` and wires up `Add-ShellContextMenuHandler`, so right-clicking the menu item triggers the native Windows shell context menu for that executable.
- Shift+Click on application items triggers `Add-ShiftClickHandler`, which runs the target with `-Verb RunAs`.

### Key functions

| Function | Purpose |
|----------|---------|
| `Toast` | Shows a Windows toast notification using `Windows.UI.Notifications` WinRT APIs; registers a custom app ID in the registry so toasts are attributable |
| `Install-Application` | Calls `winget install` silently; calls `WingetCheck` first |
| `WingetCheck` | Bootstraps winget by downloading the MSIX bundle if `winget.exe` is missing |
| `ClickPaste` | Downloads, extracts, and launches ClickPaste; attempts to pin it to the system tray via registry |
| `Load-GifFromURL` | Downloads a GIF from a URL and sets `$pictureBox.Image` directly from a MemoryStream |
| `Set-FormBottomRight` | Positions the form in the bottom-right corner of a given screen's working area |

### Drag-and-drop
The form has `AllowDrop = $true`. `DragEnter` sets the effect to `Copy`. `DragDrop` accepts either a file path (`.gif` only) or a URL string, and replaces the current buddy GIF. URLs go through `Load-GifFromURL`; file paths load the `.gif` directly from disk.

### `#region` structure
The script body is organized into regions: `Functions` → base64 icon variables → tray setup → `Buddies` → `Applications` → `Customize Windows` → `Installs` → `Scripts` → `Handlers` (drag-drop, tray events) → `Application.Run`.

### v2.0 → v2.1 differences
v2.1 (`Start-WizardBuddy-v2.ps1`) adds: embedded C# `ShellContextMenu` (replaces COM-based approach), `Add-SubMenuItem`/`Add-ShiftClickHandler` helpers, `WingetCheck` bootstrap, and `Add-Type -AssemblyName` (replacing deprecated `LoadWithPartialName`).

### v3.1 additions (ported from Combat-Hounds, 2026-09-28)
The helpers are copied from `C:\Projects\Combat-Hounds\Combat-Hounds.ps1`, so a fix to one should usually go to both.
- **Customize Windows** is table-driven: `$CustomizeRows` → `Add-TweakMenuItems`. Each tweak is a toggle: a check (refreshed from the registry on `DropDownOpening` via `Test-TweakApplied`) marks applied tweaks, and clicking a checked one undoes it (`Set-RegistryAndRestartExplorer -Undo`). Every tweak uses the cog `$SettingsIcon`; "All of the Below" keeps its own icon, covers every row without `ExcludeFromAll` (Hide Widgets is excluded), and asks before undoing. Unlike Combat-Hounds, each row is stored in the menu item's `.Tag`, because the buddy menu is rebuilt every time the buddy is shown.
- **Speed Test** (still under Scripts) is `Show-SpeedTest`, built with `New-OpsHubWindow` (Tokyo Night, OpsHub title bar). The test runs in the background via `Start-BackgroundTask` / `Invoke-SpeedTest` (`$BackgroundFunctions` lists only `Invoke-SpeedTest`). `Show-TrayNotice` reports the result if the window was closed first.
- The menu is built inside the tray left-click handler and the buddy is shown with `ShowDialog()`, so menu handlers can see that handler's local variables through PowerShell's dynamic scoping. Don't wrap them in `.GetNewClosure()`.
- Known pre-existing bug: the buddy's keep-on-top `$timer` is never stopped when the buddy closes, so after Hide it throws on `$form.TopMost` every second (invisible, because the console is hidden).

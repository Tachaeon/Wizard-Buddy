# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Wizard-Buddy is a PowerShell Windows Forms application that places an animated GIF companion in the system tray and optionally on the desktop. The right-click tray menu exposes admin utilities, one-click winget installs, registry tweaks, and buddy-swapping. The entire application is self-contained — all GIF and icon assets are Base64-encoded and embedded directly in the script, requiring no external files at runtime.

## Running

```powershell
# Requires PowerShell 7+
pwsh Start-WizardBuddy.ps1

# Or as designed (via VBScript launcher, hidden window):
# CreateObject("Wscript.Shell").Run "powershell ... irm <url> | iex", 0, False
```

## File Map

| File | Purpose |
|------|---------|
| `Start-WizardBuddy.ps1` | **Active version (v3.3.0)** — the only script that ships; older builds moved to `Old/` on 2026-09-29 |
| `Old/Start-WizardBuddy-v2.ps1` | Previous version (v2.1) |
| `Old/Start-WizardBuddy.ps1` | Older version (v2.0) — uses deprecated `LoadWithPartialName`; kept for reference |
| `Base Wizard/Get-Wizard.ps1` | Minimal prototype — borderless form with a PictureBox and one GIF, no tray |
| `Old/ShellContextMenu.ps1` | Standalone PowerShell shell context menu helper (COM-based); v2.1 onwards use an embedded C# version instead |

## Architecture (`Start-WizardBuddy.ps1`)

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

### v3.2 additions (2026-09-29)
- The buddy's `PictureBox.MouseDown` handler now multiplexes three gestures: middle-click → `Open-BuddyClipboardUrl`, left double-click (`$e.Clicks -ge 2`) → `Start-BuddyShell`, plain left → the existing `WM_NCLBUTTONDOWN` drag. Double-click is read from the `Clicks` count instead of `Add_DoubleClick` because the drag enters a modal move loop that would otherwise swallow it.
- `Start-BuddyShell` prefers `$env:ProgramFiles\PowerShell\7\pwsh.exe` and falls back to Windows PowerShell; Shift elevates, and a dismissed UAC prompt (`NativeErrorCode 1223`) is swallowed silently.
- `Get-ClipboardWebUrl` reads `Get-Clipboard -Raw`, takes the first non-empty line, prefixes a bare host with `https://`, and returns a `[uri]` only for `http`/`https` after `[uri]::TryCreate` — so a file path or command on the clipboard is never executed. It reports refusals through `Show-TrayNotice` and is shared by `Open-BuddyClipboardUrl` (host browser) and the Clipboard Website sandbox item.
- **Windows Sandbox** gained two items: `Start-SandboxSession -Name -LogonCommand` writes a throwaway `.wsb` to `$env:TEMP\WizardBuddy`, XML-escapes the logon command and launches it. "PowerShell in Sandbox" passes `cmd.exe /c start powershell.exe -NoExit -NoLogo`; "Clipboard Website in Sandbox" passes a `powershell.exe -Command` that sleeps 5 seconds (the sandbox shell isn't ready at logon) then launches Edge by path with the URL as an argument. `Test-WindowsSandbox` holds the "install the optional feature?" prompt the two older items still inline.
- **Password Generator, Scroll Jiggler and SimpleHelp Spy Detection** were rebuilt on `New-OpsHubWindow` (`Show-PasswordGenerator`, `Show-ScrollJiggler`, `Show-SimpleHelpSpyDetection`), so the menu handlers are now one-liners. They follow the Speed Test pattern: build the body XAML, look up elements through `$UI`, report through `Set-UIStatus`. (Since v3.3.0 they open modeless; see below.)
  - Password Generator: `New-RandomPassword` is now a top-level function (it was defined inside the old `Start-Job`); generating copies to the clipboard. The password field is a read-only `TextBox` with `BorderBrush="Transparent"` — the shared TextBox template hardcodes `BorderThickness="1"`, so setting `BorderThickness="0"` does nothing.
  - Scroll Jiggler and the spy watcher use `DispatcherTimer`s that are stopped in `Window.Add_Closed`.
  - The spy watcher still runs as the background job named `SimpHelp`, so it keeps watching after the window closes; the window polls the job and `$env:TEMP\Logix.txt` every 5 seconds (`Update-SpyDetectionUI`).

### v3.2.1 (2026-09-29)
- "Clipboard Website in Sandbox" no longer hands the URL to the sandbox shell. A fresh sandbox has no http/https handler, so `Start-Process $Url` there only raises the "We can't open this 'https' link" dialog — which is not a terminating error, so the old `try`/`catch` fallback to `msedge.exe` never ran. The logon command now resolves `msedge.exe` itself (`Program Files (x86)` → `Program Files` → bare name) and passes the URL as an argument. Everything inside the `-Command` string is single-quoted, because the string is already wrapped in the double quotes of `-Command`.

### v3.3.0 (2026-09-30)
- The computer-name item is now the first entry in the buddy menu, followed by a separator.
- **Tool windows are modeless.** Speed Test, Password Generator, Scroll Jiggler and SimpleHelp Spy Detection open through `Show-ToolWindow` (`Window.Show()`) instead of `ShowDialog()`, so the buddy menu stays usable. Because their handlers now run after the `Show-*` function has returned, they can no longer see its locals by dynamic scoping:
  - `Show-ToolWindow` stores the `$UI` table in `Window.Tag`; timers keep it in `DispatcherTimer.Tag`. Every handler starts with `$UI = Get-ToolUI $this`. Per-window state (`$UI.Timer`, `$UI.Jiggles`, `$UI.LogPath`) lives in `$UI`, not in function locals. Don't use `.GetNewClosure()` instead: the closure's module scope can't see the script-scope functions when the app is run with `-File`.
  - `$ToolWindows` (script scope) maps tool name → open window. `Resume-ToolWindow` at the top of each `Show-*` brings an open instance to the front instead of opening a second; the window unregisters itself on `Closed`.
  - `Show-ToolWindow` calls `ElementHost.EnableModelessKeyboardInterop`, without which a modeless WPF window under the WinForms message loop receives no keystrokes.
  - The buddy is still shown with `ShowDialog()`, and a WinForms modal loop disables **every** window on the thread (verified), including tool windows opened before the buddy was reopened. The buddy's `Shown` handler calls `Enable-ToolWindows` (`Win32WB.UserWB.EnableWindow`) to undo that.
- Other UI-thread waits moved off the thread: `Install-Application` waits on the winget window through `Start-BackgroundTask` and launches `-PostInstallPath` in `OnComplete` (only if it exists); the PuTTY application item now calls `Install-Application` (its winget window no longer uses `-NoExit`); Group Policy Update runs `gpupdate` as a background task; Ping Google no longer passes `-Wait`; the Sandbox Proxy clipboard watch is a 1-second WinForms `Timer` that gives up after 10 minutes instead of a busy `while ($true)` loop.
- **Base64 Wizard is built in.** `Get-Base64.ps1` is gone (it only worked when `$PSScriptRoot` was set, i.e. never via `irm | iex`). `Show-Base64Wizard` is an OpsHub tool window like the others (modeless, `Resume-ToolWindow 'Base64Wizard'`): drop a file on the `DropZone` border or use Choose File to copy its Base64 to the clipboard (`ConvertTo-Base64Clipboard`, refuses folders and files over 50 MB); Decode Clipboard (`Save-Base64Clipboard`) strips an optional `data:...;base64,` prefix and writes `Downloads\Base64-<timestamp>.<ext>`, with the extension from `Get-Base64FileExtension` (leading-byte signatures, `bin` when unrecognised). Fixes carried over from the old script: EXE (`MZ`) was never detected because a 2-byte signature was compared against 4 bytes, and an unknown type silently saved nothing but still reported success.

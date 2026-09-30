
# Wizard-Buddy Tray Application
- A pixel wizard lives in the Windows system tray (bottom right).

![Wizard Tray Icon](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/WizardTray.png)

- Interaction:
-  **Left-click** → Shows Wizard-Buddy on the desktop.

![Wizard Left Click](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/WizardLeftClickTray.png)
-  **Right-click** → Opens context menus, Help and Exit.

![Wizard Right Click Tray](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/WizardRightClickTray.png)

## 📂 Context Menu Categories
### 1. Buddies
![Buddies Menu](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/WizardRightClickContextMenuBuddies.png)

- Fun companions/mascots you can swap:
- Bonzi, Carlton, Clippy, Ducky, Dumpster Fire, Linus, Nyan, PBJT, Purple Stud, Snoopy, Toaster, Travolta, Wizard, Yin Yang

### 2. Applications
![Applications Menu](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/WizardRightClickContextMenuApps.png)

- A toolbox of apps and utilities:
- Command Prompt, PowerShell, PowerShell 7, PowerShell ISE
- Computer Management, Group Policy Update, Hyper-V Manager, MMC, Network Connections
- Password Generator, Base64 Wizard, Click Paste, Scroll Jiggler
- Registry, System Properties, Task Manager, Task Scheduler

### 3. Customize Windows
![Customize Windows Menu](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/WizardRightClickContextMenuCustWin.png)
- Quick tweaks for Windows UI and behavior:
- Dark Mode
- Old Context Menu
- Remove Teams Icon
- Remove Search Bar
- Remove Task View Button
- Show Hidden Extensions
- Per-display Taskbar Buttons
-  **All of the Below** (apply everything)

### 4. Installs
![Installs Menu](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/WizardRightClickContextMenuInstalls.png)
- Shortcut installers for common tools:
- 7-Zip, Brave, Firefox, Google Chrome, VLC, Visual Studio Code, WinDirStat
- Active Directory, RSAT Tools, Group Policy
- PowerShell 7, PuTTY, Sandbox, Click Paste

### 5. Scripts
![Scripts Menu](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/WizardRightClickContextMenuScripts.png)
- Networking and utility scripts:
- Speed Test
- Ping Google
- SimpleHelp Spy Detection — watches for extra Remote Access processes, chimes and logs the time
- (Extensible: more PowerShell or batch scripts can be added)

### 6. Windows Sandbox
- Windows Sandbox — launch Windows Sandbox (offers to install the feature if missing)
- Windows Sandbox Proxy — CC Proxy running inside a sandbox; the proxy IP is copied to your clipboard
- **PowerShell in Sandbox** — a throwaway sandbox that logs on with a PowerShell window already open
- **Clipboard Website in Sandbox** — a throwaway sandbox that browses to whatever web address is on your clipboard, so an untrusted link never touches your own browser. A bare host like `google.com` becomes `https://google.com`; anything that isn't an http/https address is refused with a tray notice.

### 7. Hide
- Hides Wizard-Buddy from the desktop while keeping tray controls available.

## Other Features
- **Base64 Wizard** is built in (no extra script): drop a file on it, or choose one, to copy its Base64 to the clipboard; or copy Base64 text and click **Decode Clipboard** to save the file to Downloads with the right extension.
- Speed Test, Password Generator, Scroll Jiggler, SimpleHelp Spy Detection and Base64 Wizard all share the same dark, rounded OpsHub-style window. They open alongside the buddy instead of blocking it, so you can keep using the menu while one is open; picking one that is already open brings it to the front.
- Installs, Group Policy Update, Ping Google and the Sandbox Proxy no longer freeze the menu while they run.
- **Double-click Wizard-Buddy** → opens PowerShell 7 (falls back to Windows PowerShell if 7 isn't installed). Hold **Shift** while double-clicking to run it as Administrator.
- **Middle-click Wizard-Buddy** → opens whatever web address is on your clipboard in your default browser. A bare host like `google.com` is treated as `https://google.com`; anything that isn't an http/https address is ignored with a tray notice.
- Click and drag any .gif onto Wizard-Buddy to change it to that .gif! Even works from web browsers. (File has to be .gif)
- Shift + Left Click on most Applications to run them in Administrator context.
- Hover your mouse over Wizard-Buddy, then mousewheel up and down to increase and decrease its size.

## Summary
**Wizard-Buddy** is a fun yet powerful **launcher and customization tool**.

It bundles admin utilities, quick installers, scripts, and Windows tweaks into a playful wizard-themed UI.
## Available Buddies
| Buddy    | Preview |
|----------|---------|
| Bonzi    | ![Bonzi](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/Gifs/Bonzi.gif)        |
| Carlton  |![Carlton](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/Gifs/Carlton.gif)         |
| Clippy   |![Clippy](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/Gifs/Clippy.gif)         |
| Ducky    |![Ducky](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/Gifs/Ducky.gif)         |
| Dumpster |![Dumpster](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/Gifs/Dumpster.gif)         |
| Link     |![Link](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/Gifs/Link.gif)         |
| Linus    |![Linus](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/Gifs/Linus.gif)         |
| Nyan     |![Nyan](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/Gifs/Nyan.gif)         |
| PBJT     |![PBJT](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/Gifs/PBJT.gif)         |
| Snoopy   |![Snoopy](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/Gifs/Snoopy.gif)         |
| Stud     |![Stud](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/Gifs/Stud.gif)         |
| Toaster  |![Toaster](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/Gifs/Toaster.gif)         |
| Travolta |![Travolta](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/Gifs/Travolta.gif)         |
| Wizard   | ![Wizard](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/Gifs/Wizard.gif) |
| YinYang  |![YinYang](https://raw.githubusercontent.com/Tachaeon/Wizard-Buddy/refs/heads/main/Images/Gifs/YinYang.gif)         |

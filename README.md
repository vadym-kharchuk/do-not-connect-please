# macOS Bluetooth Auto-Connect Fix

Prevent a specific Bluetooth device from auto-connecting on macOS login, with a simple CLI to connect/disconnect on demand.

## Requirements

```bash
brew install blueutil
```

## Install

```bash
git clone https://github.com/vadymkharchuk/macos-bluetooth-autoconnect-fix
cd macos-bluetooth-autoconnect-fix
chmod +x install.sh
./install.sh
```

The installer will list all your paired Bluetooth devices and let you pick one:

```
Scanning for paired Bluetooth devices...

Select a device to manage:

   1)  AirPods Pro  (aa-bb-cc-dd-ee-ff)
   2)  Monitor 2    (11-22-33-44-55-66)
   3)  Magic Mouse  (99-88-77-66-55-44)

Enter number [1-3]: 2

Selected: Monitor 2 (11-22-33-44-55-66)
Installed successfully!
```

Make sure `~/.local/bin` is in your PATH (add to `~/.zshrc` if needed):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

```bash
monitor2        # connect
monitor2 off    # disconnect
```

On every login, the selected device is automatically disconnected after 10 seconds.

To change the device, run `./install.sh` again.

## Files

| File | Purpose |
|------|---------|
| `install.sh` | Interactive device picker, installs everything |
| `disconnect-monitor2.sh` | Runs on login, disconnects the selected device after 10s |
| `monitor2.sh` | CLI installed as `monitor2` |
| `com.user.disconnect-monitor2.plist` | LaunchAgent template |

Device config is stored at `~/.config/monitor2/device` (not tracked by git).

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.user.disconnect-monitor2.plist
rm ~/Library/LaunchAgents/com.user.disconnect-monitor2.plist
rm ~/.local/bin/disconnect-monitor2.sh
rm ~/.local/bin/monitor2
rm -rf ~/.config/monitor2
```

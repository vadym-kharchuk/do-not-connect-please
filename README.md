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

Make sure `~/.local/bin` is in your PATH (add to `~/.zshrc` if needed):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

```bash
monitor2        # connect Monitor 2
monitor2 off    # disconnect Monitor 2
```

On every login, the device is automatically disconnected after 10 seconds, preventing macOS from auto-connecting it.

## Files

| File | Purpose |
|------|---------|
| `disconnect-monitor2.sh` | Runs on login, disconnects the device after a 10s delay |
| `monitor2.sh` | CLI script installed as `monitor2` |
| `com.user.disconnect-monitor2.plist` | LaunchAgent that triggers `disconnect-monitor2.sh` on login |
| `install.sh` | Installs all files and loads the LaunchAgent |

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.user.disconnect-monitor2.plist
rm ~/Library/LaunchAgents/com.user.disconnect-monitor2.plist
rm ~/.local/bin/disconnect-monitor2.sh
rm ~/.local/bin/monitor2
```

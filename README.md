# do-not-connect-please

Prevent a Bluetooth device from auto-connecting on macOS login, with a simple CLI to connect/disconnect on demand.

## Requirements

```bash
brew install blueutil
```

## Install

```bash
git clone https://github.com/vadymkharchuk/do-not-connect-please
cd do-not-connect-please
chmod +x install.sh
./install.sh
```

The installer lists all your paired Bluetooth devices and lets you pick one:

```
Scanning for paired Bluetooth devices...

Select a device to manage:

   1)  AirPods Pro   (aa-bb-cc-dd-ee-ff)
   2)  Monitor 2     (11-22-33-44-55-66)
   3)  Magic Mouse   (99-88-77-66-55-44)

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
do-not-connect-please        # connect
do-not-connect-please off    # disconnect
```

On every login, the selected device is automatically disconnected after 10 seconds.

To change the device, run `./install.sh` again.

## Files

| File | Purpose |
|------|---------|
| `install.sh` | Interactive device picker, installs everything |
| `bt-disconnect-on-login.sh` | Runs on login, disconnects the selected device after 10s |
| `do-not-connect-please.sh` | CLI installed as `do-not-connect-please` |
| `com.user.do-not-connect-please.plist` | LaunchAgent template |

Device config is stored at `~/.config/do-not-connect-please/device` (not tracked by git).

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.user.do-not-connect-please.plist
rm ~/Library/LaunchAgents/com.user.do-not-connect-please.plist
rm ~/.local/bin/bt-disconnect-on-login
rm ~/.local/bin/do-not-connect-please
rm -rf ~/.config/do-not-connect-please
```

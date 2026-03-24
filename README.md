# do-not-connect-please

Prevent Bluetooth devices from auto-connecting on macOS login, with a simple CLI to connect/disconnect on demand.

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

The installer lists all your paired Bluetooth devices and lets you pick one or more:

```
Scanning for paired Bluetooth devices...

Select devices to manage (space-separated numbers, e.g. 1 3):

   1)  AirPods Pro   (aa-bb-cc-dd-ee-ff)
   2)  Monitor 2     (11-22-33-44-55-66)
   3)  Magic Mouse   (99-88-77-66-55-44)

Enter numbers [1-3]: 1 2

Selected devices:
  - AirPods Pro
  - Monitor 2

Installed successfully!
```

Make sure `~/.local/bin` is in your PATH (add to `~/.zshrc` if needed):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

```bash
do-not-connect-please              # list configured devices
do-not-connect-please on           # connect all
do-not-connect-please on <name>    # connect by name
do-not-connect-please off          # disconnect all
do-not-connect-please off <name>   # disconnect by name
```

On every login, all configured devices are automatically disconnected after 10 seconds.

To change the selection, run `./install.sh` again.

## Files

| File | Purpose |
|------|---------|
| `install.sh` | Interactive device picker, installs everything |
| `bt-disconnect-on-login.sh` | Runs on login, disconnects all configured devices after 10s |
| `do-not-connect-please.sh` | CLI installed as `do-not-connect-please` |
| `com.user.do-not-connect-please.plist` | LaunchAgent template |

Device config is stored at `~/.config/do-not-connect-please/devices` (not tracked by git).

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.user.do-not-connect-please.plist
rm ~/Library/LaunchAgents/com.user.do-not-connect-please.plist
rm ~/.local/bin/bt-disconnect-on-login
rm ~/.local/bin/do-not-connect-please
rm -rf ~/.config/do-not-connect-please
```

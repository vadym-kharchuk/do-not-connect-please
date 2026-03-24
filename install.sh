#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
PLIST="com.user.do-not-connect-please.plist"
CONFIG_FILE="$HOME/.config/do-not-connect-please/devices"

# Remove macOS quarantine flag (set on files downloaded from the internet)
xattr -r -d com.apple.quarantine "$SCRIPT_DIR" 2>/dev/null || true

# Check blueutil
if ! command -v blueutil &>/dev/null; then
  echo "blueutil not found. Install it with: brew install blueutil"
  exit 1
fi

echo "Scanning for paired Bluetooth devices..."
echo ""

DEVICES=()
while IFS= read -r line; do
  DEVICES+=("$line")
done < <(blueutil --paired | sed -n 's/.*address: \([^,]*\).*name: "\([^"]*\)".*/\1|\2/p')

if [ ${#DEVICES[@]} -eq 0 ]; then
  echo "No paired Bluetooth devices found."
  exit 1
fi

echo "Select devices to manage (space-separated numbers, e.g. 1 3):"
echo ""
for i in "${!DEVICES[@]}"; do
  ADDR=$(echo "${DEVICES[$i]}" | cut -d'|' -f1)
  NAME=$(echo "${DEVICES[$i]}" | cut -d'|' -f2-)
  printf "  %2d)  %s  (%s)\n" $((i+1)) "$NAME" "$ADDR"
done
echo ""

while true; do
  read -rp "Enter numbers [1-${#DEVICES[@]}]: " -a CHOICES
  VALID=true
  for C in "${CHOICES[@]}"; do
    if ! [[ "$C" =~ ^[0-9]+$ ]] || [ "$C" -lt 1 ] || [ "$C" -gt "${#DEVICES[@]}" ]; then
      echo "Invalid choice: $C. Try again."
      VALID=false
      break
    fi
  done
  [ "$VALID" = true ] && [ ${#CHOICES[@]} -gt 0 ] && break
done

# Save config (one address|name per line)
mkdir -p "$(dirname "$CONFIG_FILE")"
> "$CONFIG_FILE"
echo ""
echo "Selected devices:"
for C in "${CHOICES[@]}"; do
  ENTRY="${DEVICES[$((C-1))]}"
  echo "$ENTRY" >> "$CONFIG_FILE"
  NAME=$(echo "$ENTRY" | cut -d'|' -f2-)
  echo "  - $NAME"
done
echo ""

# Install scripts
mkdir -p "$BIN_DIR"

cp "$SCRIPT_DIR/do-not-connect-please.sh" "$BIN_DIR/do-not-connect-please"
chmod +x "$BIN_DIR/do-not-connect-please"

cp "$SCRIPT_DIR/bt-disconnect-on-login.sh" "$BIN_DIR/bt-disconnect-on-login"
chmod +x "$BIN_DIR/bt-disconnect-on-login"

# Install LaunchAgent (with resolved path to script)
sed "s|SCRIPT_PATH|$BIN_DIR/bt-disconnect-on-login|g" \
  "$SCRIPT_DIR/com.user.do-not-connect-please.plist" \
  > "$LAUNCH_AGENTS/$PLIST"

# Load LaunchAgent
launchctl unload "$LAUNCH_AGENTS/$PLIST" 2>/dev/null || true
launchctl load "$LAUNCH_AGENTS/$PLIST"

echo "Installed successfully!"
echo "These devices will be disconnected automatically on login."
echo ""
echo "Usage:"
echo "  do-not-connect-please            — list configured devices"
echo "  do-not-connect-please on         — connect all"
echo "  do-not-connect-please on <name>  — connect by name"
echo "  do-not-connect-please off        — disconnect all"
echo "  do-not-connect-please off <name> — disconnect by name"
echo ""
echo "Make sure $BIN_DIR is in your PATH:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""

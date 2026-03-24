#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
PLIST="com.user.do-not-connect-please.plist"
CONFIG_FILE="$HOME/.config/do-not-connect-please/device"

# Check blueutil
if ! command -v blueutil &>/dev/null; then
  echo "blueutil not found. Install it with: brew install blueutil"
  exit 1
fi

echo "Scanning for paired Bluetooth devices..."
echo ""

# Get paired devices as array of "address name"
DEVICES=()
while IFS= read -r line; do
  DEVICES+=("$line")
done < <(blueutil --paired | sed -n 's/.*address: \([^,]*\).*name: "\([^"]*\)".*/\1|\2/p')

if [ ${#DEVICES[@]} -eq 0 ]; then
  echo "No paired Bluetooth devices found."
  exit 1
fi

echo "Select a device to manage:"
echo ""
for i in "${!DEVICES[@]}"; do
  ADDR=$(echo "${DEVICES[$i]}" | cut -d'|' -f1)
  NAME=$(echo "${DEVICES[$i]}" | cut -d'|' -f2-)
  printf "  %2d)  %s  (%s)\n" $((i+1)) "$NAME" "$ADDR"
done
echo ""

while true; do
  read -rp "Enter number [1-${#DEVICES[@]}]: " CHOICE
  if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "${#DEVICES[@]}" ]; then
    break
  fi
  echo "Invalid choice, try again."
done

SELECTED="${DEVICES[$((CHOICE-1))]}"
DEVICE_ADDR=$(echo "$SELECTED" | cut -d'|' -f1)
DEVICE_NAME=$(echo "$SELECTED" | cut -d'|' -f2-)

echo ""
echo "Selected: $DEVICE_NAME ($DEVICE_ADDR)"
echo ""

# Save config
mkdir -p "$(dirname "$CONFIG_FILE")"
printf "%s\n%s\n" "$DEVICE_ADDR" "$DEVICE_NAME" > "$CONFIG_FILE"

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
echo ""
echo "  $DEVICE_NAME will be disconnected automatically on login."
echo ""
echo "Usage:"
echo "  do-not-connect-please        — connect"
echo "  do-not-connect-please off    — disconnect"
echo ""
echo "Make sure $BIN_DIR is in your PATH:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""

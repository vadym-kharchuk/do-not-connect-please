#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
PLIST="com.user.disconnect-monitor2.plist"
CONFIG_FILE="$HOME/.config/monitor2/device"

# Check blueutil
if ! command -v blueutil &>/dev/null; then
  echo "blueutil not found. Install it with: brew install blueutil"
  exit 1
fi

echo "Scanning for paired Bluetooth devices..."
echo ""

# Get paired devices as array of "address name"
mapfile -t DEVICES < <(blueutil --paired | awk -F'address: | name: |,' '{print $2, $4}' | sed 's/^ *//;s/ *$//')

if [ ${#DEVICES[@]} -eq 0 ]; then
  echo "No paired Bluetooth devices found."
  exit 1
fi

echo "Select a device to manage:"
echo ""
for i in "${!DEVICES[@]}"; do
  ADDR=$(echo "${DEVICES[$i]}" | awk '{print $1}')
  NAME=$(echo "${DEVICES[$i]}" | cut -d' ' -f2-)
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
DEVICE_ADDR=$(echo "$SELECTED" | awk '{print $1}')
DEVICE_NAME=$(echo "$SELECTED" | cut -d' ' -f2-)

echo ""
echo "Selected: $DEVICE_NAME ($DEVICE_ADDR)"
echo ""

# Save config
mkdir -p "$(dirname "$CONFIG_FILE")"
printf "%s\n%s\n" "$DEVICE_ADDR" "$DEVICE_NAME" > "$CONFIG_FILE"

# Install scripts
mkdir -p "$BIN_DIR"

cp "$SCRIPT_DIR/disconnect-monitor2.sh" "$BIN_DIR/disconnect-monitor2.sh"
chmod +x "$BIN_DIR/disconnect-monitor2.sh"

cp "$SCRIPT_DIR/monitor2.sh" "$BIN_DIR/monitor2"
chmod +x "$BIN_DIR/monitor2"

# Install LaunchAgent (with resolved path to script)
sed "s|SCRIPT_PATH|$BIN_DIR/disconnect-monitor2.sh|g" \
  "$SCRIPT_DIR/com.user.disconnect-monitor2.plist" \
  > "$LAUNCH_AGENTS/$PLIST"

# Load LaunchAgent
launchctl unload "$LAUNCH_AGENTS/$PLIST" 2>/dev/null || true
launchctl load "$LAUNCH_AGENTS/$PLIST"

echo "Installed successfully!"
echo ""
echo "  $DEVICE_NAME will be disconnected automatically on login."
echo ""
echo "Usage:"
echo "  monitor2        — connect"
echo "  monitor2 off    — disconnect"
echo ""
echo "Make sure $BIN_DIR is in your PATH:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""

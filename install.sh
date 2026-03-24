#!/bin/bash
set -e

DEVICE="9c-0d-ac-04-c8-b1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
PLIST="com.user.disconnect-monitor2.plist"

# Check blueutil
if ! command -v blueutil &>/dev/null; then
  echo "blueutil not found. Install it with: brew install blueutil"
  exit 1
fi

# Create bin dir
mkdir -p "$BIN_DIR"

# Install scripts
cp "$SCRIPT_DIR/disconnect-monitor2.sh" "$BIN_DIR/disconnect-monitor2.sh"
chmod +x "$BIN_DIR/disconnect-monitor2.sh"

cp "$SCRIPT_DIR/monitor2.sh" "$BIN_DIR/monitor2"
chmod +x "$BIN_DIR/monitor2"

# Install LaunchAgent
cp "$SCRIPT_DIR/$PLIST" "$LAUNCH_AGENTS/$PLIST"

# Load LaunchAgent
launchctl unload "$LAUNCH_AGENTS/$PLIST" 2>/dev/null || true
launchctl load "$LAUNCH_AGENTS/$PLIST"

echo "Installed. Make sure $BIN_DIR is in your PATH."
echo ""
echo "Usage:"
echo "  monitor2        # connect"
echo "  monitor2 off    # disconnect"

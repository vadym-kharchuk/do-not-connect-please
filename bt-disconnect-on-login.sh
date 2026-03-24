#!/bin/bash
CONFIG_FILE="$HOME/.config/do-not-connect-please/device"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "No device configured. Run install.sh first."
  exit 1
fi

DEVICE_ADDR=$(sed -n '1p' "$CONFIG_FILE")

sleep 10  # Wait for Bluetooth stack to settle after login
/opt/homebrew/bin/blueutil --disconnect "$DEVICE_ADDR"

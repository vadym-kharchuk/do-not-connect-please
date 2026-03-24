#!/bin/bash
CONFIG_FILE="$HOME/.config/do-not-connect-please/devices"

if [ ! -f "$CONFIG_FILE" ]; then
  exit 0
fi

sleep 10  # Wait for Bluetooth stack to settle after login

while IFS= read -r line; do
  ADDR=$(echo "$line" | cut -d'|' -f1)
  /opt/homebrew/bin/blueutil --disconnect "$ADDR"
done < "$CONFIG_FILE"

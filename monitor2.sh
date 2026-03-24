#!/bin/bash
CONFIG_FILE="$HOME/.config/monitor2/device"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "No device configured. Run install.sh first."
  exit 1
fi

DEVICE_ADDR=$(sed -n '1p' "$CONFIG_FILE")
DEVICE_NAME=$(sed -n '2p' "$CONFIG_FILE")

case "$1" in
  off)
    blueutil --disconnect "$DEVICE_ADDR" && echo "$DEVICE_NAME disconnected"
    ;;
  *)
    blueutil --connect "$DEVICE_ADDR" && echo "$DEVICE_NAME connected"
    ;;
esac

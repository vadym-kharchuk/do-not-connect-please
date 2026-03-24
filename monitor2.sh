#!/bin/bash
DEVICE="9c-0d-ac-04-c8-b1"

case "$1" in
  off)
    blueutil --disconnect "$DEVICE" && echo "Monitor 2 disconnected"
    ;;
  *)
    blueutil --connect "$DEVICE" && echo "Monitor 2 connected"
    ;;
esac

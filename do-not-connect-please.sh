#!/bin/bash
CONFIG_FILE="$HOME/.config/do-not-connect-please/devices"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "No devices configured. Run install.sh first."
  exit 1
fi

ACTION="$1"
FILTER="$2"

do_action() {
  local addr="$1"
  local name="$2"
  if [ "$ACTION" = "off" ]; then
    blueutil --disconnect "$addr" && echo "$name disconnected"
  else
    blueutil --connect "$addr" && echo "$name connected"
  fi
}

case "$ACTION" in
  on|off)
    while IFS= read -r line; do
      ADDR=$(echo "$line" | cut -d'|' -f1)
      NAME=$(echo "$line" | cut -d'|' -f2-)
      if [ -z "$FILTER" ] || echo "$NAME" | grep -qi "$FILTER"; then
        do_action "$ADDR" "$NAME"
      fi
    done < "$CONFIG_FILE"
    ;;
  *)
    echo "Configured devices:"
    while IFS= read -r line; do
      NAME=$(echo "$line" | cut -d'|' -f2-)
      ADDR=$(echo "$line" | cut -d'|' -f1)
      echo "  - $NAME  ($ADDR)"
    done < "$CONFIG_FILE"
    echo ""
    echo "Usage:"
    echo "  do-not-connect-please on         — connect all"
    echo "  do-not-connect-please on <name>  — connect by name"
    echo "  do-not-connect-please off        — disconnect all"
    echo "  do-not-connect-please off <name> — disconnect by name"
    ;;
esac

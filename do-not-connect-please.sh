#!/bin/bash
CONFIG_FILE="$HOME/.config/do-not-connect-please/devices"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "No devices configured. Run install.sh first."
  exit 1
fi

# Load devices into array
DEVICES=()
while IFS= read -r line; do
  DEVICES+=("$line")
done < "$CONFIG_FILE"

print_list() {
  for i in "${!DEVICES[@]}"; do
    NAME=$(echo "${DEVICES[$i]}" | cut -d'|' -f2-)
    ADDR=$(echo "${DEVICES[$i]}" | cut -d'|' -f1)
    printf "  %d)  %s  (%s)\n" $((i+1)) "$NAME" "$ADDR"
  done
}

do_action() {
  local action="$1"
  local addr="$2"
  local name="$3"
  if [ "$action" = "off" ]; then
    blueutil --disconnect "$addr" && echo "$name disconnected"
  else
    blueutil --connect "$addr" && echo "$name connected"
  fi
}

ACTION="$1"
ARG="$2"

case "$ACTION" in
  on|off)
    if [ -n "$ARG" ]; then
      # Connect/disconnect by number
      if ! [[ "$ARG" =~ ^[0-9]+$ ]] || [ "$ARG" -lt 1 ] || [ "$ARG" -gt "${#DEVICES[@]}" ]; then
        echo "Invalid number. Configured devices:"
        print_list
        exit 1
      fi
      ENTRY="${DEVICES[$((ARG-1))]}"
      do_action "$ACTION" "$(echo "$ENTRY" | cut -d'|' -f1)" "$(echo "$ENTRY" | cut -d'|' -f2-)"
    else
      # Connect/disconnect all
      for entry in "${DEVICES[@]}"; do
        do_action "$ACTION" "$(echo "$entry" | cut -d'|' -f1)" "$(echo "$entry" | cut -d'|' -f2-)"
      done
    fi
    ;;
  *)
    echo "Configured devices:"
    print_list
    echo ""
    echo "Usage:"
    echo "  do-not-connect-please on      — connect all"
    echo "  do-not-connect-please on 2    — connect device #2"
    echo "  do-not-connect-please off     — disconnect all"
    echo "  do-not-connect-please off 2   — disconnect device #2"
    ;;
esac

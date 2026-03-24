#!/bin/bash
# Disconnect "Monitor 2" headphones to prevent auto-connection
sleep 10  # Wait for Bluetooth stack to settle after login
/opt/homebrew/bin/blueutil --disconnect 9c-0d-ac-04-c8-b1

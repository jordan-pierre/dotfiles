#!/bin/bash
# Fires on permission_prompt and idle_prompt notification events

input=$(cat)
notification_type=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('notification_type',''))" 2>/dev/null)

case "$notification_type" in
  permission_prompt)
    afplay /System/Library/Sounds/Funk.aiff &>/dev/null &
    ;;
  idle_prompt)
    afplay /System/Library/Sounds/Tink.aiff &>/dev/null &
    ;;
  *)
    afplay /System/Library/Sounds/Tink.aiff &>/dev/null &
    ;;
esac

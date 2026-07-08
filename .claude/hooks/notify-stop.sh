#!/bin/bash
# Fires when Claude finishes a task (Stop event)
input=$(cat)
if echo "$input" | grep -q '"stop_hook_active":true'; then
  exit 0
fi

afplay /System/Library/Sounds/Glass.aiff &>/dev/null &

#!/bin/bash

# Kill existing polybar instances
killall -q polybar

# Wait until they're fully closed
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar on all connected monitors
for monitor in $(xrandr --query | grep " connected" | cut -d" " -f1); do
  MONITOR=$monitor polybar --reload main &
done

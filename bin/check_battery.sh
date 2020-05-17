#!/bin/bash

LIMIT=15
BAT=$(/usr/bin/upower -e | grep BAT)
POW=$(/usr/bin/upower -i $BAT | grep --color=never -E percentage|xargs|cut -d' ' -f2|sed s/%//)
CHARGING=$(/usr/bin/upower -i $BAT | grep -q 'state:\s*charging' && echo 1 || echo 0)

# DBUS_SESSION_FILE=~/.dbus/session-bus/$(cat /var/lib/dbus/machine-id)-0
# if [ -e "$DBUS_SESSION_FILE" ]; then
#     . "$DBUS_SESSION_FILE"
#     export DBUS_SESSION_BUS_ADDRESS DBUS_SESSION_BUS_PID
# fi
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus


if [[ "$CHARGING" -eq "0" ]] && (($POW < $LIMIT)); then
    /usr/bin/notify-send -u critical -t 15000 "Low battery: $POW%"
fi

#/bin/bash
#
# This is the reminder for the MinuteMail
# It will be called via cron every day at 18:30

# specify display for cron
export DISPLAY=:0.0

# in order to use notify-send, this needs to be here to call the script
# in .dbus
if [ -r "$HOME/.dbus/Xdbus" ]; then
  . "$HOME/.dbus/Xdbus"
fi

# Here are the contents of the file:
# DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
# export DBUS_SESSION_BUS_ADDRESS

# run the actual thing
if [ ! -f "/home/bene/bin/mm/sent" ]; then
  /usr/bin/notify-send -t 1000 -i /usr/share/icons/Vibrancy-Colors/apps/256/email.png MinuteMail "Time to send your MinuteMail"
  sleep 1
  xterm -geometry 100x55 -e /home/bene/bin/./mmail.sh remind
else
  rm /home/bene/bin/mm/sent
fi

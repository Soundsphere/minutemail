#!/bin/bash
#
# MinuteMail script created by Benedikt Rumpf, System Administrator at
# Caroobi GmbH
# This script sends out a MinuteMail our managers and teammates.
# It will be constantly updated and improved. Should you be able to script
# in bash and come across this file, please feel free improve and or otherwise
# use this script.
# Before using this program, have a look at
# https://wiki.archlinux.org/index.php/SSMTP in order to install the mailer
# have a look at getopt for better case handling.

# Path to files
MM="$HOME/bin/mm"

# Source mm.conf
# Set your recipients in this config file
source $HOME/bin/mm.conf

# todays date. Format: Weekday, DD Month YYYY
NOW=$(date +%A,\ %d.\ %B\ %Y)

# combine all files to one
function catall() {
  cat $MM/{Header,Worked,Roadblocks,Observations,Thoughts,Feelings,Footer} > "$MM/MinuteMail"
}

# reset all the files after send
function reset() {
  printf "\n\nWorked on:" > "$MM/Worked"
  printf "\n\nFeelings:" > "$MM/Feelings"
  printf "\n\nRoadblocks:" > "$MM/Roadblocks"
  printf "\n\nObservations:" > "$MM/Observations"
  printf "\n\nThoughts:" > "$MM/Thoughts"
  if [ -f "$MM/MinuteMail" ]; then
    rm "$MM/MinuteMail"
    echo "mm reset"
  else
    echo "Nothing to do, mm already reset"
  fi
}

# send the MinuteMail
# the file "sent" gets created for the cronjob. If the file does not exist,
# run the cron to notify me of the MinuteMail that I have to send
function sendmm() {
  mail -s "MinuteMail Benedikt - $NOW" $mm_recipients < "$MM/MinuteMail"
  echo "mail sent"
  reset
  touch "$MM/sent"
}

# program begins here
case $1 in
  w)      printf "\n - %b" "$2" >> "$MM/Worked"
  ;;
  r)      printf "\n - %b" "$2" >> "$MM/Roadblocks"
  ;;
  o)      printf "\n - %b" "$2" >> "$MM/Observations"
  ;;
  t)      printf "\n - %b" "$2" >> "$MM/Thoughts"
  ;;
  f)      printf "\n - %b" "$2" >> "$MM/Feelings"
  ;;
  c)      catall
          cat "$MM/MinuteMail"
  ;;
  d)      catall
          cat "$MM/MinuteMail"
          printf "\n\n"
          read -p "Edit (e) or send (s) MinuteMail? " edit
          case $edit in
            e)  nano "$MM/MinuteMail"
                printf "\n\n"
                read -p "Send now (s)?" send
                case $send in
                  s) sendmm
                  ;;
                  *)  echo "not sent"
                esac
            ;;
            s)  sendmm
            ;;
            *) echo "not sent"
          esac
  ;;
  s)      catall
          sendmm
  ;;
  # this section is called from the reminder script
  # it opens an xterm and closes it right after the interaction
  remind) catall
          cat "$MM/MinuteMail"
          printf "\n\n"
          read -p "Edit (e) or send (s) MinuteMail? " edit
          case $edit in
            e)  nano "$MM/MinuteMail"
                printf "\n\n"
                read -p "Send now (s)?" send
                case $send in
                  s)  sendmm
                      exit
                  ;;
                  *)  echo "not sent"
                esac
            ;;
            s)  sendmm
                exit
            ;;
            *) echo "not sent"
          esac
  ;;
  help)   cat "$MM/Helpfile"
  ;;
  reset)  reset
  ;;
  test)   catall
          mail -s "MinuteMail Benedikt - $NOW" $mm_debug < "$MM/MinuteMail"
          touch "$MM/sent"
          echo "mail sent, but not reset"
  ;;
  *)      echo "Invalid or no option given. Please see mm help for further info"
esac

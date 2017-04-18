#!/bin/bash
#
# This script sends out a MinuteMail to our managers.
# It will be constantly updated and improved. Should you be able to script
# in bash and come across this file, please feel free improve and or otherwise
# use this script.
# Before using this program, have a look at
# https://wiki.archlinux.org/index.php/SSMTP in order to install the mailer
# have a look at getopt for better case handling.

# Source mm.conf
# The recipients and the working directory are set in this file
source ./mm.conf

# todays date. Format: Weekday, DD Month YYYY
NOW=$(date +%A,\ %d.\ %B\ %Y)

# combine all files to one
function catall() {
  cat $mm_dir/{Header,Worked,Roadblocks,Observations,Thoughts,Feelings,Footer} > "$mm_dir/MinuteMail"
}

# reset all the files after send
function reset() {
  if [ -f "$mm_dir/MinuteMail" ]; then
    printf "\nWorked on:" > "$mm_dir/Worked"
    printf "\n\nFeelings:" > "$mm_dir/Feelings"
    printf "\n\nRoadblocks:" > "$mm_dir/Roadblocks"
    printf "\n\nObservations:" > "$mm_dir/Observations"
    printf "\n\nThoughts:" > "$mm_dir/Thoughts"
    rm "$mm_dir/MinuteMail"
    echo "mm reset"
  else
    echo "Nothing to do, mm already reset"
  fi
}

# send the MinuteMail
# the file "sent" gets created for the cronjob. If the file does not exist,
# run the cron to notify me of the MinuteMail that I have to send
function sendmm() {
  mail -s "MinuteMail Benedikt - $NOW" $mm_recipients < "$mm_dir/MinuteMail"
  echo "mail sent"
  cp "$mm_dir/MinuteMail" "$mm_dir/history/MinuteMail $NOW"
  reset
  touch "$mm_dir/sent"
}

# program begins here
case $1 in
  w)      printf "\n - %b" "$2" >> "$mm_dir/Worked"
  ;;
  r)      printf "\n - %b" "$2" >> "$mm_dir/Roadblocks"
  ;;
  o)      printf "\n - %b" "$2" >> "$mm_dir/Observations"
  ;;
  t)      printf "\n - %b" "$2" >> "$mm_dir/Thoughts"
  ;;
  f)      printf "\n - %b" "$2" >> "$mm_dir/Feelings"
  ;;
  c)      catall
          cat "$mm_dir/MinuteMail"
  ;;
  d)      catall
          cat "$mm_dir/MinuteMail"
          printf "\n\n"
          read -p "Edit (e) or send (s) MinuteMail? " edit
          case $edit in
            e)  nano "$mm_dir/MinuteMail"
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
          cat "$mm_dir/MinuteMail"
          printf "\n\n"
          read -p "Edit (e) or send (s) MinuteMail? " edit
          case $edit in
            e)  nano "$mm_dir/MinuteMail"
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
  help)   cat "$mm_dir/Helpfile"
  ;;
  reset)  reset
  ;;
  test)   catall
          mail -s "MinuteMail Benedikt - $NOW" $mm_dir_debug < "$mm_dir/MinuteMail"
          touch "$mm_dir/sent"
          echo "mail sent, but not reset"
  ;;
  *)      echo "Invalid or no option given. Please see mm help for further info"
esac

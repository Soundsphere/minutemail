#!/bin/bash
#
# MinuteMail script created by Benedikt Rumpf, System Administrator at
# Caroobi GmbH
# This script sends out a MinuteMail to 1mm@caroobi.com, product@caroobi.com
# and noida.tech@caroobi.com
# It will be constantly updated and improved. Should you be able to script
# in bash and come across this file, please feel free improve and or otherwise
# use this script.
# Before using this program, have a look at
# https://wiki.archlinux.org/index.php/SSMTP in order to install the mailer
#
###############################################################################
# Bug seems to be fixed, keep an eye on how it performs in the wild
###############################################################################

# Path to files
MM="$HOME/bin/mm"

# recipients of the email
#DEST="emailhere"
# uncomment for debugging:
DEST="emailhere"

# todays date. Format: Weekday, DD Month YYYY
NOW=$(date +%A,\ %d.\ %B\ %Y)

# combine all files to one
function catall() {
  cat $MM/Header $MM/Worked $MM/Roadblocks $MM/Observations $MM/Thoughts $MM/Feelings $MM/Footer > $MM/MinuteMail
}

# reset all the files after send
function reset() {
  printf "Worked on:" > $MM/Worked
  printf "\n\nFeelings:" > $MM/Feelings
  printf "\n\nRoadblocks:" > $MM/Roadblocks
  printf "\n\nObservations:" > $MM/Observations
  printf "\n\nThoughts:" > $MM/Thoughts
  if [ -f "$MM/MinuteMail" ]; then
    rm $MM/MinuteMail
    echo "mm reset"
  else
    echo "Nothing to do, mm already reset"
  fi
}

# send the MinuteMail
function sendmm() {
  cat $MM/MinuteMail | mail -s "MinuteMail Benedikt - $NOW" $DEST
  echo "mail sent"
  reset
  touch $MM/sent
}

# program begins here
case $1 in
  w)      printf "\n - $2" >> $MM/Worked
  ;;
  r)      printf "\n - $2" >> $MM/Roadblocks
  ;;
  o)      printf "\n - $2" >> $MM/Observations
  ;;
  t)      printf "\n - $2" >> $MM/Thoughts
  ;;
  f)      printf "\n - $2" >> $MM/Feelings
  ;;
  check)  catall
          cat $MM/MinuteMail
  ;;
  done)   catall
          cat $MM/MinuteMail
          printf "\n\n"
          read -p "Edit (e) or send (s) MinuteMail? " edit
          case $edit in
            e)  nano $MM/MinuteMail
                printf "\n\n"
                read -p "Send now? " send
                case $send in
                  y) sendmm
                  ;;
                  *)  echo "not sent"
                esac
            ;;
            s)  sendmm
            ;;
            *) echo "not sent"
          esac
  ;;
  send)   sendmm
  ;;
  # this section is called from the reminder script
  # it opens an xterm and closes it right after the interaction
  remind) catall
          cat $MM/MinuteMail
          printf "\n\n"
          read -p "Edit (e) or send (s) MinuteMail? " edit
          case $edit in
            e)  nano $MM/MinuteMail
                printf "\n\n"
                read -p "Send now? " send
                case $send in
                  y)  sendmm
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
  help)   cat $MM/Helpfile
  ;;
  status) catall
          cat $MM/MinuteMail
  ;;
  reset)  reset
  ;;
  test)   catall
          cat $MM/MinuteMail | mail -s "MinuteMail Benedikt - $NOW" $DEST
          touch $MM/sent
          echo "mail sent, but not reset"
  ;;
  *)      echo "Invalid or no option given. Please see mm help for further info"
esac

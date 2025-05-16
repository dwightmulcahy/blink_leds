#!/bin/bash

# based on this article: https://opensource.com/article/20/6/find-raspberry-pi
# updated with info on latest kernel: https://forums.raspberrypi.com/viewtopic.php?t=352416

# make sure that this is being run as root
if ! [ $(id -u) = 0 ]; then
   echo "Must be run as root."
   exit 1
fi

echo "Raspberry Pi LED Blinker"

set -o errexit
set -o nounset

# trap CTRL-C and kill to reset all the LED states
trap quit INT TERM
function quit {
  echo ""
  echo "Setting led0 trigger back to [${ENABLED_LED0}]"
  echo "${ENABLED_LED0}" >"${LED0_TRIGGER}"
  echo "${BRIGHTNESS_LED0}" >"${LED0_BRIGHTNESS}"
  echo "Setting led1 trigger back to [${ENABLED_LED1}]"
  echo "${ENABLED_LED1}" >"${LED1_TRIGGER}"
  echo "${BRIGHTNESS_LED1}" >"${LED1_BRIGHTNESS}"
}

# set up the constants for turning the LEDs on/off
ON=1
OFF=0

# the legacy (Buster) version of Raspberry Pi OS uses
# led0 and led1 names whereas the recent kernel version
# uses ACT and PWR for those names.
#
# make sure the directories exist for the LEDs
LED0="/sys/class/leds/led0"
if [ ! -d "$LED0" ]
then
  LED0="/sys/class/leds/ACT"
fi

LED1="/sys/class/leds/led1"
if [ ! -d "$LED1" ]
then
  LED1="/sys/class/leds/PWR"
fi

# verify that we have valid directories for the LEDs
if [ ! -d "$LED0" ] || [ ! -d "$LED1" ]
then
  echo "Unable to find directories for LEDs."
fi

# set up the trigger and brightness directory constants
LED0_TRIGGER="${LED0}/trigger"
LED1_TRIGGER="${LED1}/trigger"
LED0_BRIGHTNESS="${LED0}/brightness"
LED1_BRIGHTNESS="${LED1}/brightness"

# get the current trigger and brightness settings for the LEDs
ENABLED_LED0=$(cat "${LED0_TRIGGER}" | sed -n -r 's/.*\[(.*)\].*/\1/p')
BRIGHTNESS_LED0=$(cat "${LED0_BRIGHTNESS}")
ENABLED_LED1=$(cat "${LED1_TRIGGER}" | sed -n -r 's/.*\[(.*)\].*/\1/p')
BRIGHTNESS_LED1=$(cat "${LED1_BRIGHTNESS}")


echo -n "Blinking Raspberry Pi's LEDs - press CTRL-C to quit"

# turn off the triggers for the LEDs
echo none >"${LED0_TRIGGER}"
echo none >"${LED1_TRIGGER}"

# loop through blinking LEDs for one minute or till CTRL-C is pressed
COUNT=0
while true
do
  let "COUNT=COUNT+1"
  if [[ $COUNT -lt 20 ]]
  then
    echo "${ON}" > "${LED0_BRIGHTNESS}"
    echo "${OFF}" > "${LED1_BRIGHTNESS}"
    sleep 1
    echo "${ON}" > "${LED0_BRIGHTNESS}"
    echo "${ON}" > "${LED1_BRIGHTNESS}"
    sleep 1
    echo "${OFF}" > "${LED0_BRIGHTNESS}"
    echo "${ON}" > "${LED1_BRIGHTNESS}"
    sleep 1
  else
    quit
    break
  fi
done


#!/bin/bash

set -o errexit
set -o nounset

# trap CTRL-C and kill
trap quit INT TERM

# make sure that this is being run as root
if ! [ $(id -u) = 0 ]; then
   echo "Must be run as root."
   exit 1
fi

# set up all the directory constants
LED0="/sys/class/leds/led0"
LED1="/sys/class/leds/led1"
LED0_TRIGGER="${LED0}/trigger"
LED1_TRIGGER="${LED1}/trigger"
LED0_BRIGHTNESS="${LED0}/brightness"
LED1_BRIGHTNESS="${LED1}/brightness"
ON=1
OFF=0

# make sure the directories exist
if [ ! -d "$LED0" ]
then
  echo "Could not find an LED at ${LED0}"
  echo "Perhaps try '/sys/class/leds/ACT'?"
  exit 1
fi
if [ ! -d "$LED1" ]
then
  echo "Could not find an LED at ${LED1}"
  echo "Perhaps try '/sys/class/leds/ACT'?"
  exit 1
fi

# get the current trigger and brightness settings for the LEDs
ENABLED_LED0=$(cat "${LED0_TRIGGER}" | sed -n -r 's/.*\[(.*)\].*/\1/p')
BRIGHTNESS_LED0=$(cat "${LED0_BRIGHTNESS}")
ENABLED_LED1=$(cat "${LED1_TRIGGER}" | sed -n -r 's/.*\[(.*)\].*/\1/p')
BRIGHTNESS_LED1=$(cat "${LED1_BRIGHTNESS}")

# trap will call this to reset all the LED states
function quit {
  echo ""
  echo "Setting led0 trigger back to [${ENABLED_LED0}]"
  echo "${ENABLED_LED0}" >"${LED0_TRIGGER}"
  echo "${BRIGHTNESS_LED0}" >"${LED0_BRIGHTNESS}"
  echo "Setting led1 trigger back to [${ENABLED_LED1}]"
  echo "${ENABLED_LED1}" >"${LED1_TRIGGER}"
  echo "${BRIGHTNESS_LED1}" >"${LED1_BRIGHTNESS}"
}

echo -n "Blinking Raspberry Pi's LEDs - press CTRL-C to quit"

# turn off the triggers for the LEDs
echo none >"${LED0_TRIGGER}"
echo none >"${LED1_TRIGGER}"

# loop through blinking LEDs for one minute or till CTRL-C is pressed
COUNT=0
while true
do
  let "COUNT=COUNT+1"
  if [[ $COUNT -lt 30 ]]
  then
    echo "${ON}" > "${LED0_BRIGHTNESS}"
    echo "${OFF}" > "${LED1_BRIGHTNESS}"
    sleep 1
    echo "${OFF}" > "${LED0_BRIGHTNESS}"
    echo "${ON}" > "${LED1_BRIGHTNESS}"
    sleep 1
  else
    quit
    break
  fi
done

# blink_leds

This little script will alternatingly blink the two  LEDs on the front of a Raspberry Pi.

You will need to `ssh` into the pi that you want to blink the LEDs on.

## Installing blink_leds.sh
```bash
curl -L https://raw.githubusercontent.com/dwightmulcahy/blink_leds/master/blink_leds.sh > blink_leds.sh
chmod +x blink_leds.sh
```

## Running blink_leds
```bash
sudo ./blink_leds.sh
```

This will print the message `Blinking Raspberry Pi's LEDs - press CTRL-C to quit` and will continue to alternate blink the red and green LEDs on the front of the raspberry pi.`
Pressing CTRL-C will stop the lights from blinking and set the LED states back to what they were before.

# Steps to set up a raspberry pi controller for the actuators

## Connect a relay for a pump

1. Refer to the following schematics: ![relay-to-pump-connection](imgs/relay-to-pump-connection.png)
2. Use the library from git as referenced in the other module

### Example script

```python
import RPi.GPIO as GPIO
from time import sleep


def pump_water(sec, pump_pin):
    print("Pumping water for {} seconds...".format(sec))

    # set GPIO mode and set up the pump pin
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(pump_pin, GPIO.OUT)

    try:
        # turn the pump off for 0.25 seconds
        GPIO.output(pump_pin, GPIO.LOW)
        sleep(0.25)

        # turn the pump on for the given time
        GPIO.output(pump_pin, GPIO.HIGH)
        sleep(sec)

        # turn the pump off
        GPIO.cleanup()

        print("Done pumping water.")

    except KeyboardInterrupt:
        # stop pump when ctrl-c is pressed
        GPIO.cleanup()
```

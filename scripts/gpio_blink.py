#!/usr/bin/env python3
# Minimal GPIO blink script for Raspberry Pi (Zero 2 W).
# Usage: python3 gpio_blink.py <BCM_PIN> <COUNT>

import sys, time

try:
    import RPi.GPIO as GPIO
except Exception as e:
    print("RPi.GPIO not available:", e)
    sys.exit(0)  # Allow non-Pi development without failing

if len(sys.argv) < 3:
    print("Usage: gpio_blink.py <BCM_PIN> <COUNT>")
    sys.exit(1)

pin = int(sys.argv[1])
count = int(sys.argv[2])

GPIO.setmode(GPIO.BCM)
GPIO.setup(pin, GPIO.OUT)

try:
    for _ in range(count):
        GPIO.output(pin, GPIO.HIGH)
        time.sleep(0.2)
        GPIO.output(pin, GPIO.LOW)
        time.sleep(0.2)
finally:
    GPIO.cleanup()
    print(f"Blinked pin {pin} for {count} times.")

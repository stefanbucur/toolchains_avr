A simple program for the [AVR128DB48 Curiosity Nano](https://www.microchip.com/en-us/development-tool/ev35l43a) board that pulses the built-in LED using PWM and a button to pause/resume.

## Usage

```sh
bazel build -c opt --config=avr //:pulse_led
```

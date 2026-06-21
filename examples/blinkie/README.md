C firmware examples for the [AVR128DB48 Curiosity Nano](https://www.microchip.com/en-us/development-tool/ev35l43a) board.

## hello

Button (PB2) toggles the on-board LED (PB3) via a GPIO interrupt, sleeping between presses.

```sh
bazel build -c opt --config=avr //src/hello:hello
bazel run --config=avr //src/hello:flash
```

## pulse

PWM-driven LED brightness pulse with a button to pause/resume; demonstrates decomposing a project into multiple Bazel libraries.

```sh
bazel build -c opt --config=avr //src/pulse:pulse_led
bazel run --config=avr //src/pulse:flash
```

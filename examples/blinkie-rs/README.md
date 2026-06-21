Rust firmware examples for the [AVR128DB48 Curiosity Nano](https://www.microchip.com/en-us/development-tool/ev35l43a) board.

## hello

Bare-metal `no_std` Rust firmware that loops forever — a minimal starting point.

```sh
bazel build -c opt --config=avr //src/hello:hello
bazel run --config=avr //src/hello:flash
```

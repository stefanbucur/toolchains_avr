# toolchains_avr

> **Community project.** `toolchains_avr` is an independent, community-maintained project. It is not affiliated with, endorsed by, or officially supported by Microchip Technology, the Bazel authors, or any other organization.

Bazel rules for AVR microcontroller development, supporting both C/C++ and Rust.

[AVR](https://www.microchip.com/en-us/products/microcontrollers-and-microprocessors/8-bit-mcus/avr-mcus) is Microchip's family of 8-bit microcontrollers, widely used in embedded systems and popularized by the Arduino platform.

[Bazel](https://bazel.build) is a build system designed around hermetic, reproducible builds and a powerful dependency model. `toolchains_avr` leverages Bazel's extensibility mechanism to make AVR firmware development deterministic and easy to set up.

## Features

- **General purpose** — targets any AVR MCU hardware, thanks to Bazel's powerful platform specification mechanism ("bring your own hardware"). This makes `toolchains_avr` ideal for hobbyists designing their own boards.
- **Batteries included** — automatically downloads and configures the avr-gcc and Rust toolchains needed to build firmware; no manual toolchain installation required.
- **Deterministic builds** — generated firmware is expected to be identical across machines and CI environments.
- **Easy modularity** — code can be naturally organized into libraries using Bazel's build graph.
- **Reusable packages** — libraries can be published as standalone Bazel modules and shared across projects; Bazel effectively acts as a package manager for AVR firmware.
- **C/C++ and Rust** — both languages are supported and can coexist in the same module.

## Getting Started

This guide walks through setting up a new Bazel project targeting the **AVR128DB48 Curiosity Nano** development board. By the end, you'll have a working firmware build and IDE code completion for AVR headers.

> The complete source for this example lives in [`examples/blinkie/`](examples/blinkie/).

### 1. Install Bazel

We recommend installing via [Bazelisk](https://github.com/bazelbuild/bazelisk), which automatically selects the right Bazel version for each project.

**Linux:**
```sh
sudo bash -c 'curl -f -L https://github.com/bazelbuild/bazelisk/releases/download/v1.27.0/bazelisk-linux-amd64 \
    -o /usr/local/bin/bazelisk \
    && chmod +x /usr/local/bin/bazelisk \
    && ln -sf /usr/local/bin/bazelisk /usr/local/bin/bazel'
```

**macOS:**
```sh
brew install bazelisk
```

### 2. Create the project

Create a new directory for your project:

```sh
mkdir my_project && cd my_project
```

Pin the Bazel version by writing `.bazelversion`:

```
9.0.2
```

Create `MODULE.bazel` to declare `toolchains_avr` as a dependency and configure the avr-gcc toolchain. Bazel will download the toolchain automatically on first build — no manual installation needed.

```python
bazel_dep(name = "rules_cc", version = "0.2.17")
bazel_dep(name = "toolchains_avr", version = "0.1.0", repo_name = "avr")

avr_gcc = use_extension("@avr//cc:extensions.bzl", "avr")
avr_gcc.toolchain(
    distro = "avr-toolchain-gcc15.2.0-libc2.3.1-binutils2.46",
)

register_toolchains("@avr//cc/toolchain:all")
```

### 3. Write the first source file and BUILD

Create `src/hello/hello_main.c` with a minimal main loop:

```c
#include <avr/io.h>

int main(void) {
    while (1) {}
}
```

Create `src/hello/BUILD` to declare the firmware target:

```python
load("@avr//cc:defs.bzl", "avr_cc_binary")

avr_cc_binary(
    name = "hello",
    srcs = ["hello_main.c"],
)
```

Now try to build the target directly:

```sh
bazel build //src/hello:hello
```

The build fails because `avr_cc_binary` targets are only compatible with AVR platforms — Bazel doesn't yet know you want to cross-compile for AVR:

```
ERROR: Target //src/hello:hello is incompatible and cannot be built, but was explicitly requested.
Constraints that are not satisfied:
  @avr//avr/platform:cpu_avr
```

### 4. Define the platform and build

Create a root `BUILD` file that describes your target hardware:

```python
platform(
    name = "curiosity_board",
    constraint_values = [
        "@avr//avr/platform:cpu_avr",
        "@avr//avr/platform:os_none",
        "@avr//avr/platform:avr128db48",
    ],
)
```

The three constraints tell Bazel: this is an AVR CPU, bare-metal (no OS), and specifically an AVR128DB48. `toolchains_avr` uses the MCU constraint to inject the right `-mmcu=avr128db48` flag into the compiler invocation.

Pass the platform on the command line:

```sh
bazel build --platforms=//:curiosity_board //src/hello:hello
```

The build now succeeds and produces two outputs:

- `bazel-bin/src/hello/hello.elf` — ELF binary (for debugging with a JTAG probe)
- `bazel-bin/src/hello/hello.hex` — Intel HEX file (for flashing)

### 5. Save the platform config to `.bazelrc`

Typing `--platforms=...` every time is tedious. Save it as a named config in `.bazelrc` at the project root:

```
build:avr --platforms=//:curiosity_board
```

Now use the short form:

```sh
bazel build --config=avr //src/hello:hello
```

### 6. Flash the firmware

Install [avrdude](https://github.com/avrdude/avrdude) on your host system, then add an `avrdude_flash` target to `src/hello/BUILD`:

```python
load("@avr//avr:defs.bzl", "avrdude_flash")
load("@avr//cc:defs.bzl", "avr_cc_binary")

avr_cc_binary(
    name = "hello",
    srcs = ["hello_main.c"],
)

avrdude_flash(
    name = "flash",
    src = ":hello",
    programmer = "pkobn_updi",
)
```

`avrdude_flash` automatically injects `-p avr128db48` (from the active platform constraint), `-c pkobn_updi` (from the `programmer` attribute), and `-U flash:w:<hex>:i` (from the `src` target). Plug in your Curiosity Nano and run:

```sh
bazel run --config=avr //src/hello:flash
```

Bazel builds the firmware if needed, then runs avrdude. The full command is printed before execution so you can inspect or copy-paste it for manual use:

```
avrdude -p avr128db48 -c pkobn_updi -U flash:w:bazel-bin/src/hello/hello.hex:i
```

### 7. Write the full firmware

Replace `src/hello/hello_main.c` with the complete LED-toggle example. The program configures PB3 as an LED output and PB2 as a button input with a falling-edge interrupt. The CPU sleeps between button presses to keep power consumption low.

```c
#define F_CPU 4000000UL  // AVR128DB48 default clock after reset.

#include <avr/interrupt.h>
#include <avr/io.h>
#include <avr/sleep.h>
#include <util/delay.h>

ISR(PORTB_PORT_vect) {
    if (PORTB.INTFLAGS & PIN2_bm) {
        // Simple debounce: wait 10ms and check if button is still pressed.
        _delay_ms(10);
        if (!(PORTB.IN & PIN2_bm)) {  // PB2 still LOW means button held.
            PORTB.OUTTGL = PIN3_bm;   // Toggle the LED on PB3.
        }
        PORTB.INTFLAGS = PIN2_bm;  // Clear flag (write 1 to clear).
    }
}

int main(void) {
    // LED on PB3: output, initially off.
    PORTB.DIRSET = PIN3_bm;
    PORTB.OUTCLR = PIN3_bm;

    // Button on PB2: input with pull-up, interrupt on falling edge.
    PORTB.DIRCLR = PIN2_bm;
    PORTB.PIN2CTRL = PORT_PULLUPEN_bm | PORT_ISC_FALLING_gc;

    // Sleep in idle mode; CPU wakes on button interrupt.
    SLPCTRL.CTRLA = SLPCTRL_SMODE_IDLE_gc | SLPCTRL_SEN_bm;

    sei();
    while (1) {
        sleep_cpu();
    }
}
```

This code uses AVR128DB48-specific peripheral registers. Add `compatible_mcus` to `src/hello/BUILD` so Bazel rejects the target on incompatible MCUs with a clear error instead of a cryptic compile failure:

```python
load("@avr//avr:defs.bzl", "avrdude_flash")
load("@avr//cc:defs.bzl", "avr_cc_binary")

avr_cc_binary(
    name = "hello",
    srcs = ["hello_main.c"],
    compatible_mcus = ["avr128db48"],
)

avrdude_flash(
    name = "flash",
    src = ":hello",
    programmer = "pkobn_updi",
)
```

Flash the updated firmware directly — Bazel detects that the source changed, rebuilds the firmware, and reflashes in one step:

```sh
bazel run --config=avr //src/hello:flash
```

### 8. Add IDE support

For code completion and go-to-definition in VS Code (or any editor using `clangd`), add [Hedron's compile commands extractor](https://github.com/hedronvision/bazel-compile-commands-extractor) to `MODULE.bazel`:

```python
bazel_dep(name = "hedron_compile_commands", dev_dependency = True)
git_override(
    module_name = "hedron_compile_commands",
    commit = "7fe1eab26d2b8eeb5e1c6a2f38bddb001e3f9696",
    remote = "https://github.com/hedronvision/bazel-compile-commands-extractor.git",
)
```

Add a target to the root `BUILD` that lists all firmware targets you want the IDE to understand:

```python
load("@hedron_compile_commands//:refresh_compile_commands.bzl", "refresh_compile_commands")

refresh_compile_commands(
    name = "refresh_compile_commands",
    targets = {
        "//src/hello:hello": "--config=avr",
    },
)
```

Generate `compile_commands.json`:

```sh
bazel run //:refresh_compile_commands
```

`clangd` picks up the file automatically. You'll get accurate code completion, diagnostics, and go-to-definition for all AVR headers and your own code.

Rust firmware examples for the [AVR128DB48 Curiosity Nano](https://www.microchip.com/en-us/development-tool/ev35l43a) board.

## Examples

### barebones

Minimal `no_std` Rust firmware with no external dependencies. Drives PB3 low
using raw register writes and an `.init9` trampoline to hook into avr-libc's
startup sequence.

```sh
bazel build -c opt --config=avr //firmware/barebones:barebones
bazel run --config=avr //firmware/barebones:flash
```

### hello

`no_std` firmware using the [`avr-device`](https://github.com/Rahix/avr-device)
PAC crate for typed, safe register access.

```sh
bazel build -c opt --config=avr //firmware/hello:hello
bazel run --config=avr //firmware/hello:flash
```

## IDE support (rust-analyzer)

rust-analyzer is driven by a generated `rust-project.json` (AVR is a `no_std`
target with a Bazel-built `core`, so there is no Cargo project to read).
Generate or refresh it with:

```sh
bazel run //:rust_project
```

This writes `rust-project.json` at the workspace root, teaching rust-analyzer
about the AVR sysroot, the crate graph, and proc-macros. Rerun it whenever you
add/remove targets or change dependencies (analogous to
`refresh_compile_commands` for C/C++). The file embeds machine-specific cache
paths, so it is git-ignored rather than checked in.

The targets to index are declared by the `avr_rust_project` rule in the root
`BUILD` file; the build flags it uses live under `build:rust_project` in
`.bazelrc`.

### Zed

`.zed/settings.json` points rust-analyzer at the Bazel-managed server via
`rust_analyzer.sh`. Open the folder in Zed and, after running the command
above once, rust-analyzer resolves the firmware crates with no further setup.
# Copyright 2026 The toolchains_avr authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Implementation of the avrdude_flash rule and its supporting avrdude_config rule."""

load("//avr/private:firmware.bzl", "AvrFirmwareInfo")

# avrdude_config ──────────────────────────────────────────────────────────────

AvrdudeConfigInfo = provider(
    doc = "Configuration for the avrdude_flash rule.",
    fields = {"part": "The avrdude part name (e.g. 'm328p', 'avr128db48'), or '' if unknown."},
)

def _avrdude_config_impl(ctx):
    return [AvrdudeConfigInfo(part = ctx.attr.part)]

avrdude_config = rule(
    doc = """Provides avrdude configuration via AvrdudeConfigInfo.

Instantiated in avr/private/BUILD to expose the MCU-platform-derived avrdude
part as a target that the avrdude_flash rule reads via its private _avrdude_config attr.
""",
    implementation = _avrdude_config_impl,
    attrs = {
        "part": attr.string(
            doc = "The avrdude part name (e.g. 'm328p', 'avr128db48'). May use select().",
            default = "",
        ),
    },
)

# avrdude_flash ───────────────────────────────────────────────────────────────

def _avrdude_impl(ctx):
    hex_file = ctx.attr.src[AvrFirmwareInfo].hex
    avrdude_part = ctx.attr._avrdude_config[AvrdudeConfigInfo].part
    if not avrdude_part:
        fail("avrdude_flash: no avrdude part known for the selected MCU platform")

    auto_flags = ["-p", avrdude_part, "-c", ctx.attr.programmer]

    quoted_flags = " ".join(['"' + f + '"' for f in auto_flags + ctx.attr.flags])

    script_content = """\
#!/usr/bin/env bash
set -euo pipefail

RUNFILES_DIR="${{RUNFILES_DIR:-${{0}}.runfiles}}"
HEX="${{RUNFILES_DIR}}/{workspace}/{short_path}"

echo "avrdude {flags} \"-U\" \"flash:w:$HEX:i\" $@"
exec avrdude {flags} "-U" "flash:w:$HEX:i" "$@"
""".format(
        workspace = ctx.workspace_name,
        short_path = hex_file.short_path,
        flags = quoted_flags,
    )

    script = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(output = script, content = script_content, is_executable = True)

    return [DefaultInfo(
        executable = script,
        runfiles = ctx.runfiles(files = [hex_file]),
    )]

avrdude_flash = rule(
    doc = """Generates a runnable target that flashes firmware using the host avrdude.

The avrdude binary must be available on the host system PATH at run time.

The following avrdude arguments are set automatically:
  -p <part>              inferred from the active MCU platform constraint
  -c <programmer>        from the mandatory programmer attribute
  -U flash:w:<hex>:i     the firmware hex file from the src target

The full command is printed before execution so it can be inspected or
copy-pasted for manual use.

Example:
    avr_cc_binary(name = "my_binary", srcs = ["main.c"])

    avrdude_flash(
        name = "flash",
        src = ":my_binary",
        programmer = "curiosity_nano",
    )

Then flash with: bazel run //:flash
Extra run-time flags can be appended via: bazel run //:flash -- -v
""",
    implementation = _avrdude_impl,
    attrs = {
        "src": attr.label(
            doc = "An avr_firmware (or avr_cc_binary / avr_rust_binary) target to flash.",
            providers = [AvrFirmwareInfo],
            mandatory = True,
        ),
        "programmer": attr.string(
            doc = "Programmer ID passed to avrdude as -c <programmer> (e.g. 'curiosity_nano', 'pkobn_updi').",
            mandatory = True,
        ),
        "flags": attr.string_list(
            doc = "Additional flags to pass to avrdude, inserted before the automatic -U flash write.",
            default = [],
        ),
        "_avrdude_config": attr.label(
            default = "//avr/private:avrdude_config",
            providers = [AvrdudeConfigInfo],
        ),
    },
    executable = True,
)

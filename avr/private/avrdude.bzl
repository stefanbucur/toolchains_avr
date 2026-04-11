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

"""Implementation of the avrdude rule."""

load("//avr/private:firmware.bzl", "AvrFirmwareInfo")

def _avrdude_impl(ctx):
    hex_file = ctx.attr.src[AvrFirmwareInfo].hex

    # Wrap each flag in double-quotes so that $HEX (which the user may embed
    # in a flag value, e.g. "flash:w:$HEX:i") expands at run time.
    quoted_flags = " ".join(['"' + f + '"' for f in ctx.attr.flags])

    script_content = """\
#!/usr/bin/env bash
set -euo pipefail

RUNFILES_DIR="${{RUNFILES_DIR:-${{0}}.runfiles}}"
HEX="${{RUNFILES_DIR}}/{workspace}/{short_path}"

exec avrdude {flags} "$@"
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

avrdude = rule(
    doc = """Generates a runnable target that flashes firmware using the host avrdude.

The avrdude binary must be available on the host system PATH at run time.

Example:
    avr_cc_binary(name = "my_binary", srcs = ["main.c"])

    avrdude(
        name = "flash",
        src = ":my_binary",
        flags = ["-p", "avr128db28", "-c", "curiosity_nano", "-U", "flash:w:$HEX:i"],
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
        "flags": attr.string_list(
            doc = "Flags to pass to avrdude. $HEX in any flag value expands to the hex file path at run time.",
            default = [],
        ),
    },
    executable = True,
)

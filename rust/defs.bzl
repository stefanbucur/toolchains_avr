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

"""Public-facing rules for building AVR Rust firmware."""

load("@rules_rust//rust:defs.bzl", "rust_binary")
load("//avr:defs.bzl", "avr_firmware")
load("//avr/private:binary.bzl", "COMMON_AVR_BINARY_ATTRS", "avr_binary")  # buildifier: disable=bzl-visibility

def _avr_rust_binary_impl(name, visibility, compatible_mcus, **kwargs):
    avr_binary(
        rust_binary,
        name + "_bin",
        compatible_mcus,
        **kwargs
    )
    avr_firmware(
        name = name,
        src = ":" + name + "_bin",
        is_rust = True,
        visibility = visibility,
    )

avr_rust_binary = macro(
    doc = """Builds an AVR Rust binary and produces .elf and .hex outputs.

    Wraps rust_binary with AVR platform constraints, nightly channel, and fat
    LTO, then runs avr-objcopy to produce an Intel HEX file ready for
    flashing. Requires --platforms=//:avr_board (or equivalent) to select the
    target MCU.

    The intermediate ELF is available as <name>_bin.
    """,
    inherit_attrs = rust_binary,
    attrs = COMMON_AVR_BINARY_ATTRS,
    implementation = _avr_rust_binary_impl,
)

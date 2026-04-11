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

"""Common helpers for AVR binary macros."""

COMMON_AVR_BINARY_ATTRS = {
    "target_compatible_with": None,
    "compatible_mcus": attr.string_list(
        doc = "Optional list of MCU names (e.g. ['attiny10', 'atmega328p']) this binary is compatible with. When non-empty, building for any other MCU will be marked incompatible.",
        default = [],
        configurable = False,
    ),
}

def avr_binary(binary_rule, name, compatible_mcus, **kwargs):
    """Creates a binary target using binary_rule with AVR platform constraints.

    Args:
        binary_rule: The rule to invoke (e.g. cc_binary or rust_binary).
        name: Target name, already including any desired suffix (e.g. name + "_bin").
        compatible_mcus: List of MCU names to restrict compatibility to.
        **kwargs: Forwarded to binary_rule.
    """
    compat = [Label("//avr/platform:cpu_avr")]
    if compatible_mcus:
        compat = compat + select(dict(
            [(Label("//avr/platform:%s" % mcu), []) for mcu in compatible_mcus] +
            [("//conditions:default", [Label("@platforms//:incompatible")])],
        ))
    binary_rule(
        name = name,
        target_compatible_with = compat,
        **kwargs
    )

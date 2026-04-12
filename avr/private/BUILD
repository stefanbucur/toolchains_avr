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

load(":avrdude.bzl", "avrdude_config")
load(":mcus.bzl", "AVR_MCUS")

package(default_visibility = ["//visibility:public"])

avrdude_config(
    name = "avrdude_config",
    # Avrdude part name inferred from the active MCU platform constraint.
    # Resolves to the avrdude short part name (e.g. "m328p", "avr128db48") when
    # a known MCU platform is selected, and to "" when no MCU platform is active.
    part = select({
        "//avr/platform:%s" % mcu: spec.avrdude_part
        for mcu, spec in AVR_MCUS.items()
        if spec.avrdude_part != None
    } | {"//conditions:default": ""}),
)

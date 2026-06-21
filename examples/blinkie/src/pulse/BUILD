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

load("@avr//avr:defs.bzl", "avrdude_flash")
load("@avr//cc:defs.bzl", "avr_cc_binary")
load("@rules_cc//cc:cc_library.bzl", "cc_library")

cc_library(
    name = "led",
    srcs = ["led.c"],
    hdrs = ["led.h"],
)

cc_library(
    name = "button",
    srcs = ["button.c"],
    hdrs = ["button.h"],
)

avr_cc_binary(
    name = "pulse_led",
    srcs = ["pulse_led_main.c"],
    compatible_mcus = ["avr128db48"],
    deps = [
        ":button",
        ":led",
    ],
)

avrdude_flash(
    name = "flash",
    src = ":pulse_led",
    programmer = "pkobn_updi",
)

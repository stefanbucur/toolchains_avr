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

load("@bazel_skylib//rules:common_settings.bzl", "bool_flag")

package(default_visibility = ["//visibility:public"])

# Bootstrap flag — true when compiling the stdlib itself (breaks circular dep).
bool_flag(
    name = "bootstrap",
    build_setting_default = False,
)

config_setting(
    name = "is_bootstrap",
    flag_values = {"//rust/config:bootstrap": "True"},
)

# AVR flag — true when building for the AVR target.
bool_flag(
    name = "avr",
    build_setting_default = False,
)

config_setting(
    name = "is_avr",
    flag_values = {"//rust/config:avr": "True"},
)

# Host flag — true in the default (non-AVR) configuration.  Pass this as
# target_settings to rules_rust's toolchain tag so that rules_rust's bundled
# host toolchain is only eligible outside of AVR exec contexts, preventing
# it from competing with host_rust_toolchain_def when dep ordering varies.
config_setting(
    name = "is_host",
    flag_values = {"//rust/config:avr": "False"},
)

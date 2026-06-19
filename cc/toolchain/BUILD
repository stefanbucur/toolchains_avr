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

load("@rules_cc//cc/toolchains:actions.bzl", "cc_action_type")
load("@rules_cc//cc/toolchains:args.bzl", "cc_args")
load("@rules_cc//cc/toolchains:args_list.bzl", "cc_args_list")
load("//avr/private:mcus.bzl", "AVR_MCUS")  # buildifier: disable=bzl-visibility
load("//cc:avr_action_names.bzl", "AVR_ACTION_NAMES")

package(default_visibility = ["//visibility:public"])

# Args.
################################################################################

cc_args(
    name = "no_absolute_paths_for_builtins",
    actions = [
        "@rules_cc//cc/toolchains/actions:compile_actions",
    ],
    args = [
        "-no-canonical-prefixes",
        "-fno-canonical-system-headers",
    ],
)

cc_args(
    name = "optimize_for_size",
    actions = [
        "@rules_cc//cc/toolchains/actions:compile_actions",
    ],
    args = [
        "-Os",
    ],
)

cc_args(
    name = "mcu_args",
    actions = [
        "@rules_cc//cc/toolchains/actions:compile_actions",
        "@rules_cc//cc/toolchains/actions:link_actions",
    ],
    args = select({
        "//avr/platform:%s" % mcu: ["-mmcu=%s" % mcu]
        for mcu in AVR_MCUS
    }),
)

cc_args_list(
    name = "default_avr_args",
    args = [
        ":no_absolute_paths_for_builtins",
        ":optimize_for_size",
        ":mcu_args",
    ],
)

# Actions.
################################################################################

cc_action_type(
    name = "avr_nm",
    action_name = AVR_ACTION_NAMES.avr_nm,
)

cc_action_type(
    name = "avr_size",
    action_name = AVR_ACTION_NAMES.avr_size,
)

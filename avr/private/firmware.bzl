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

"""Implementation of the avr_firmware rule."""

load("@rules_cc//cc:find_cc_toolchain.bzl", "CC_TOOLCHAIN_ATTRS", "find_cc_toolchain", "use_cc_toolchain")
load("@rules_cc//cc/common:cc_common.bzl", "cc_common")

def _avr_transition_impl(_settings, attr):
    if not attr.is_rust:
        return {}
    return {
        "//rust/config:avr": True,
        "@rules_rust//rust/toolchain/channel:channel": "nightly",
        "@rules_rust//rust/settings:lto": "fat",
    }

_avr_transition = transition(
    implementation = _avr_transition_impl,
    inputs = [],
    outputs = [
        "//rust/config:avr",
        "@rules_rust//rust/toolchain/channel:channel",
        "@rules_rust//rust/settings:lto",
    ],
)

def _avr_firmware_impl(ctx):
    toolchain = find_cc_toolchain(ctx)
    src = ctx.file.src
    elf = ctx.actions.declare_file(ctx.label.name + ".elf")
    ctx.actions.symlink(output = elf, target_file = src)
    hex = ctx.actions.declare_file(ctx.label.name + ".hex")
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = toolchain,
    )
    objcopy = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = "objcopy_embed_data",
    )
    ctx.actions.run(
        inputs = [src] + toolchain.all_files.to_list(),
        outputs = [hex],
        executable = objcopy,
        arguments = ["-O", "ihex", src.path, hex.path],
        mnemonic = "AvrObjcopy",
        progress_message = "Generating AVR hex {} from {}".format(hex.path, src.path),
    )
    return [DefaultInfo(files = depset([elf, hex]))]

avr_firmware = rule(
    implementation = _avr_firmware_impl,
    attrs = {
        "src": attr.label(
            doc = "The ELF binary to convert to Intel HEX format.",
            cfg = _avr_transition,
            allow_single_file = True,
            mandatory = True,
        ),
        "is_rust": attr.bool(
            doc = "Whether to apply the Rust/AVR transition to src.",
            default = False,
        ),
    } | CC_TOOLCHAIN_ATTRS,
    toolchains = use_cc_toolchain(),
    fragments = ["cpp"],
)

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

"""Transition and sysroot rules for building Rust stdlib from source."""

def _bootstrap_transition_impl(_settings, _attr):
    return {
        "//rust/config:bootstrap": True,
        "@rules_rust//rust/toolchain/channel:channel": "nightly",
    }

_bootstrap_transition = transition(
    implementation = _bootstrap_transition_impl,
    inputs = [],
    outputs = [
        "//rust/config:bootstrap",
        "@rules_rust//rust/toolchain/channel:channel",
    ],
)

def _rust_toolchain_sysroot_impl(ctx):
    """Build a rustc sysroot layout and force bootstrap toolchain on srcs.

    Output layout: {rule_name}/lib/rustlib/{target_triple}/lib/{rlib}
    """
    out_files = []
    prefix = "%s/lib/rustlib/%s/lib" % (ctx.label.name, ctx.attr.target_triple)
    for src in ctx.files.srcs:
        out = ctx.actions.declare_file("%s/%s" % (prefix, src.basename))
        ctx.actions.symlink(output = out, target_file = src)
        out_files.append(out)
    return [DefaultInfo(files = depset(out_files))]

rust_toolchain_sysroot = rule(
    implementation = _rust_toolchain_sysroot_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "target_triple": attr.string(default = "avr-none"),
    },
    cfg = _bootstrap_transition,
)

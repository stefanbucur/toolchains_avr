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

"""Module extension for the AVR Rust toolchain."""

load("//avr/private:hosts.bzl", "detect_host_key")  # buildifier: disable=bzl-visibility
load("//rust/private:repositories.bzl", "avr_rust_toolchains")  # buildifier: disable=bzl-visibility

_toolchain_tag = tag_class(
    doc = "Configures the AVR Rust toolchain.",
    attrs = {
        "analyzer_version": attr.string(
            doc = "The version of rust-analyzer to use.",
            default = "1.94.0",
        ),
        "edition": attr.string(
            doc = "The default Rust edition for targets that do not specify one.",
            default = "2024",
        ),
        "nightly_stamp": attr.string(
            doc = "The nightly ISO date (YYYY-MM-DD) of the Rust compiler to use.",
            default = "2026-03-21",
        ),
    },
)

def _avr_impl(module_ctx):
    host_key = detect_host_key(module_ctx)
    for mod in module_ctx.modules:
        if not mod.is_root:
            continue
        for toolchain_tag in mod.tags.toolchain:
            avr_rust_toolchains(
                nightly_stamp = toolchain_tag.nightly_stamp,
                analyzer_version = toolchain_tag.analyzer_version,
                edition = toolchain_tag.edition,
                host_key = host_key,
            )

avr = module_extension(
    implementation = _avr_impl,
    os_dependent = True,
    arch_dependent = True,
    tag_classes = {
        "toolchain": _toolchain_tag,
    },
)

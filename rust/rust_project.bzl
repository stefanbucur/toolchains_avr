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

"""On-demand rust-project.json generation for AVR Rust projects.

Defines `avr_rust_project`, a Hedron-style `refresh_compile_commands` analogue:
declare it once in the workspace-root BUILD file with the firmware targets you
edit, then `bazel run` it to (re)generate a `rust-project.json` that teaches
rust-analyzer about the no_std AVR sysroot, crate graph, and proc-macros.
"""

load("@rules_shell//shell:sh_binary.bzl", "sh_binary")

def _to_crate_label(target):
    """Resolves an avr_rust_binary label to its underlying rust crate target.

    avr_rust_binary(name = "hello") expands to an avr_firmware wrapper `:hello`
    plus the actual rust_binary `:hello_bin`. The rust-analyzer aspect must run
    on the rust_binary, so we append `_bin`. Labels that already end in `_bin`
    are passed through unchanged, as are explicit `@repo//...` crate labels.
    """
    if target.endswith("_bin"):
        return target
    if ":" in target:
        return target + "_bin"

    # Package-only label like //firmware/hello -> //firmware/hello:hello_bin.
    pkg = target.rstrip("/")
    return "{}:{}_bin".format(pkg, pkg.rsplit("/", 1)[-1])

def avr_rust_project(name, targets, config = "rust_project", **kwargs):
    """Generates a rust-project.json for the given AVR Rust firmware targets.

    Usage in the workspace-root BUILD file:

        load("@avr//rust:rust_project.bzl", "avr_rust_project")

        avr_rust_project(
            name = "rust_project",
            targets = [
                "//firmware/hello:hello",
                "//firmware/barebones:barebones",
            ],
        )

    Then `bazel run //:rust_project` writes `rust-project.json` at the workspace
    root. The consumer's .bazelrc must define the referenced `config` so the
    aspect builds under the AVR rust-analyzer configuration, e.g.:

        build:rust_project --config=avr
        build:rust_project --@avr//rust/config:avr=True

    Args:
        name: Target name; also the `bazel run` entry point.
        targets: List of avr_rust_binary labels (the firmware names) to index.
            Each is resolved to its underlying `<name>_bin` rust crate.
        config: Name of the .bazelrc config supplying the AVR rust-analyzer
            build flags. Defaults to "rust_project".
        **kwargs: Forwarded to the underlying sh_binary (tags, visibility, ...).
    """
    crate_targets = [_to_crate_label(t) for t in targets]

    sh_binary(
        name = name,
        srcs = ["@avr//rust/private:gen_rust_project.sh"],
        data = ["@rules_rust//tools/rust_analyzer:gen_rust_project"],
        args = ["--config", config] + crate_targets,
        deps = ["@bazel_tools//tools/bash/runfiles"],
        tags = kwargs.pop("tags", []) + ["manual"],
        **kwargs
    )

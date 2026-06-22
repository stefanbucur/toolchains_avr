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

load("@avr//rust:rust_project.bzl", "avr_rust_project")

platform(
    name = "curiosity_board",
    constraint_values = [
        "@avr//avr/platform:cpu_avr",
        "@avr//avr/platform:os_none",
        "@avr//avr/platform:avr128db48",
    ],
)

# IDE support: `bazel run //:rust_project` regenerates rust-project.json so
# rust-analyzer (Zed, VS Code, ...) sees the AVR sysroot, crate graph, and
# proc-macros. Rerun after changing targets or dependencies.
avr_rust_project(
    name = "rust_project",
    targets = [
        "//firmware/barebones:barebones",
        "//firmware/basic-pac:basic-pac",
        "//firmware/interrupts:interrupts",
    ],
)

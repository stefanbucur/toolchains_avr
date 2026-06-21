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

platform(
    name = "curiosity_board",
    constraint_values = [
        "@avr//avr/platform:cpu_avr",
        "@avr//avr/platform:os_none",
        "@avr//avr/platform:avr128db48",
    ],
)

# Build the discover_rust_project binary used by discover_rust_project.sh.
# Run once after cloning or updating rules_rust:
#   bazel build //:discover_rust_project
alias(
    name = "discover_rust_project",
    actual = "@rules_rust//tools/rust_analyzer:discover_bazel_rust_project",
)

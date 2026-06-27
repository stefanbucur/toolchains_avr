#!/usr/bin/env bash
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
#
# Backing script for the avr_rust_project() rule. Generates a rust-project.json
# at the workspace root describing the requested AVR Rust crates, so an editor's
# rust-analyzer can resolve the no_std AVR sysroot, deps, and proc-macros.
#
# Mirrors the ergonomics of Hedron's refresh_compile_commands: `bazel run` a
# target with the targets baked in, and it writes a project file at the
# workspace root using the same (default) Bazel output base. Unlike Hedron --
# which only `aquery`s the action graph -- a rust-project.json needs real build
# artifacts (generated PAC sources, compiled proc-macro dylibs), so the
# underlying rules_rust gen_rust_project tool actually `bazel build`s an aspect.
#
# The one AVR-specific wrinkle: the rust_analyzer toolchain names the sysroot
# source tree (core) and the proc-macro server by PATH only -- those repos are
# never build inputs, so neither normal builds nor the aspect build fetch them.
# We `bazel fetch` them so the paths embedded in rust-project.json resolve.
set -euo pipefail

# --- begin runfiles.bash initialization v3 ---
# shellcheck disable=SC1090
set +e
f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null ||
  source "$0.runfiles/$f" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" 2>/dev/null | cut -f2- -d' ')" 2>/dev/null ||
  { echo >&2 "ERROR: cannot find @bazel_tools runfiles library"; exit 1; }
set -e
# --- end runfiles.bash initialization v3 ---

GEN="$(rlocation rules_rust+/tools/rust_analyzer/gen_rust_project)"
if [[ -z "${GEN:-}" || ! -x "$GEN" ]]; then
  echo >&2 "ERROR: could not locate the gen_rust_project tool in runfiles"
  exit 1
fi

# gen_rust_project (and the fetch below) must run from the user's workspace so
# repo mappings and .bazelrc configs resolve. `bazel run` sets this for us.
if [[ -z "${BUILD_WORKSPACE_DIRECTORY:-}" ]]; then
  echo >&2 "ERROR: BUILD_WORKSPACE_DIRECTORY unset; run this via 'bazel run'."
  exit 1
fi
cd "$BUILD_WORKSPACE_DIRECTORY"

# Materialize the rust-analyzer toolchain's sysroot sources (core) and the
# proc-macro server, so the path-only references embedded below resolve on disk.
echo >&2 "avr_rust_project: fetching rust-analyzer sysroot + proc-macro server ..."
bazel fetch @avr_rust_host_tools//... @avr_rust_analyzer_tools//... >&2

# Build the crates before emitting the project file. rules_rust 0.71's aspect now
# records generated-source paths and include_dirs correctly, but gen_rust_project
# still does not *build* those sources -- it only emits metadata. So a crate whose
# root is generated (e.g. an avr_device() PAC's `lib.rs`) has its `root_module`
# pointing at a file that doesn't exist on disk until something compiles the crate,
# and `device::Peripherals` (anything from a generated crate) fails to resolve.
# "$@" is `--config <config> <labels...>`, the same flags and targets
# gen_rust_project sees, so the artifacts land at the exact paths it records.
echo >&2 "avr_rust_project: building crates to materialize generated sources ..."
bazel build "$@" >&2

echo >&2 "avr_rust_project: generating rust-project.json ..."
exec "$GEN" "$@"

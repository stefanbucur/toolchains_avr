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

"""The hosts supported by the AVR toolchain extension."""

def _host_spec(*, constraint_values, cc_repo, rust_repo, rust_triple, dylib_ext):
    return struct(
        constraint_values = constraint_values,
        cc_repo = cc_repo,
        rust_repo = rust_repo,
        rust_triple = rust_triple,
        dylib_ext = dylib_ext,
    )

SUPPORTED_HOSTS = {
    "linux_x86": _host_spec(
        constraint_values = [
            "@platforms//cpu:x86_64",
            "@platforms//os:linux",
        ],
        cc_repo = "@avr_gcc_linux_x86",
        rust_repo = "@rust_tools_linux_x86",
        rust_triple = "x86_64-unknown-linux-gnu",
        dylib_ext = ".so",
    ),
    "linux_arm64": _host_spec(
        constraint_values = [
            "@platforms//cpu:aarch64",
            "@platforms//os:linux",
        ],
        cc_repo = "@avr_gcc_linux_arm64",
        rust_repo = "@rust_tools_linux_arm64",
        rust_triple = "aarch64-unknown-linux-gnu",
        dylib_ext = ".so",
    ),
    "darwin_arm64": _host_spec(
        constraint_values = [
            "@platforms//cpu:aarch64",
            "@platforms//os:macos",
        ],
        cc_repo = "@avr_gcc_darwin_arm64",
        rust_repo = "@rust_tools_darwin_arm64",
        rust_triple = "aarch64-apple-darwin",
        dylib_ext = ".dylib",
    ),
}

def detect_host_key(module_ctx):
    """Returns the host key for the current execution environment.

    Args:
      module_ctx: The module extension context, providing os.arch and os.name.

    Returns:
      A string key into SUPPORTED_HOSTS (e.g. "linux_x86", "darwin_arm64").
    """
    arch = module_ctx.os.arch
    if arch == "amd64":
        arch = "x86_64"
    if module_ctx.os.name.startswith("mac"):
        return "darwin_arm64"
    elif module_ctx.os.name.startswith("linux"):
        return "linux_arm64" if arch == "aarch64" else "linux_x86"
    else:
        fail("Unsupported host: %s %s" % (module_ctx.os.name, arch))

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

"""AVR canonical distributions."""

# The base URL of the canonical repository.
_AVR_DISTROS_BASE_URL = "https://storage.googleapis.com/avr-toolchains"

# Known archives in the canonical repository.
_AVR_GCC_CANONICAL_FILES = {
    "avr-gcc-15.2.0-libc-2.2.1-binutils-2.45_x86_64-unknown-debian.tar.gz": "31f1e3177c79ac74ee2090c217dfa03f3e72939a48d651da77658e5e5a876eec",
    "avr-gcc-15.2.0-libc-2.2.1-binutils-2.45_x86_64-unknown-debian.tar.xz": "64e91e4a7e15225606f4627ef961131c6308b99dbbec983d5a49cb7b0bf83c20",
    "avr-toolchain-gcc15.2.0-libc2.3.1-binutils2.46.0_aarch64-unknown-debian.tar.xz": "daa5e30ba9886a5ee9c8892efd293a2abcdfceca74141762f746da0eed5a71e9",
    "avr-toolchain-gcc15.2.0-libc2.3.1-binutils2.46.0_x86_64-unknown-debian.tar.xz": "06e13a26b9ae812b686fc74eb4afa49e0d65c3e53c1f59e029d9f74ac893539f",
    "avr-toolchain-gcc15.2.0-libc2.3.1-binutils2.46.0_aarch64-unknown-darwin.tar.xz": "cc0e8a388d661b0e8cc936e1647ec803ec04c37817dc791af9f2d26dd1187434",
}

_AVR_CANONICAL_DISTRO_CONFIGS = {
    "avr-toolchain-gcc15.2.0-libc2.2.1-binutils2.45": {
        "linux_arm64": "",  # Not available.
        "linux_x86": "avr-gcc-15.2.0-libc-2.2.1-binutils-2.45_x86_64-unknown-debian.tar.xz",
        "darwin_arm64": "",  # Not available.
    },
    "avr-toolchain-gcc15.2.0-libc2.3.1-binutils2.46": {
        "linux_arm64": "avr-toolchain-gcc15.2.0-libc2.3.1-binutils2.46.0_aarch64-unknown-debian.tar.xz",
        "linux_x86": "avr-toolchain-gcc15.2.0-libc2.3.1-binutils2.46.0_x86_64-unknown-debian.tar.xz",
        "darwin_arm64": "avr-toolchain-gcc15.2.0-libc2.3.1-binutils2.46.0_aarch64-unknown-darwin.tar.xz",
    },
}

AVR_CANONICAL_DISTROS = list(_AVR_CANONICAL_DISTRO_CONFIGS.keys())

def canonical_archive_url(distro, arch):
    """Returns the canonical archive URL and SHA256 for the given distribution and architecture.

    Args:
      distro: The distribution name.
      arch: The architecture name.

    Returns:
      A tuple of (url, sha256) or (None, None) if not available.
    """

    if distro not in _AVR_CANONICAL_DISTRO_CONFIGS:
        fail("Unknown distribution: %s. Available distributions: %s" % (distro, ",".join(AVR_CANONICAL_DISTROS)))

    archive = _AVR_CANONICAL_DISTRO_CONFIGS[distro].get(arch, "")
    if not archive:
        return None, None  # No archive available for this architecture.

    if archive not in _AVR_GCC_CANONICAL_FILES:
        fail("Archive '%s' not found in the canonical files." % archive)

    url = _AVR_DISTROS_BASE_URL.rstrip("/") + "/" + archive
    sha256 = _AVR_GCC_CANONICAL_FILES[archive]

    return url, sha256

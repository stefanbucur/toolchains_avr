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

"""Repository instantiation for the AVR C++ toolchain."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//avr:hosts.bzl", "SUPPORTED_HOSTS")
load("//cc/private:archives.bzl", "canonical_archive_url")

def _avr_cc_toolchains_repo_impl(repository_ctx):
    build_content = repository_ctx.read(
        repository_ctx.path(repository_ctx.attr._build_template),
    )
    repository_ctx.file("BUILD.bazel", build_content)
    repository_ctx.file("WORKSPACE.bazel", "")

_avr_cc_toolchains_repo = repository_rule(
    implementation = _avr_cc_toolchains_repo_impl,
    attrs = {
        "_build_template": attr.label(
            default = "//cc/private:BUILD.toolchains",
            allow_single_file = True,
        ),
    },
)

def _parse_url_string(url_string):
    if "|" in url_string:
        url, sha256_part = url_string.rsplit("|", 1)
        if not sha256_part.startswith("sha256:"):
            fail("Invalid custom archive format for URL '%s'" % url_string)
        sha256 = sha256_part.removeprefix("sha256:")
        return url, sha256
    else:
        return url_string, None

def avr_cc_toolchains(distro, custom_archives, host_key):
    """Instantiates all repositories needed by the AVR C++ toolchain.

    Args:
        distro: The name of the canonical AVR toolchain distribution.
        custom_archives: Dict mapping host key to a custom archive URL string.
        host_key: The key from SUPPORTED_HOSTS identifying the current host platform.
    """
    for host in SUPPORTED_HOSTS:
        custom_archive_url = custom_archives.get(host, "")
        if custom_archive_url:
            url, sha256 = _parse_url_string(custom_archive_url)
        else:
            if not distro:
                fail("No distribution specified for AVR toolchain and no custom archive provided for host '%s'." % host)
            url, sha256 = canonical_archive_url(distro, host)

        http_archive(
            name = SUPPORTED_HOSTS[host].cc_repo.removeprefix("@"),
            build_file = "//cc/toolchain:BUILD.distro_files",
            urls = [url],
            strip_prefix = "usr/local/avr",
            sha256 = sha256,
        )

        if host == host_key:
            http_archive(
                name = "avr_gcc_host_tools",
                build_file = "//cc/toolchain:BUILD.distro_files",
                urls = [url],
                strip_prefix = "usr/local/avr",
                sha256 = sha256,
            )

    _avr_cc_toolchains_repo(name = "avr_cc_toolchains")

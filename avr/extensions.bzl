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

"""Unified module extension for the AVR C++ and Rust toolchains."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//avr:hosts.bzl", "SUPPORTED_HOSTS", "detect_host_key")
load("//cc/private:archives.bzl", "AVR_CANONICAL_DISTROS", "canonical_archive_url")  # buildifier: disable=bzl-visibility
load("//cc/private:repositories.bzl", "avr_cc_toolchains")  # buildifier: disable=bzl-visibility
load("//rust/private:repositories.bzl", "avr_rust_toolchains")  # buildifier: disable=bzl-visibility

_cc_toolchain_tag = tag_class(
    doc = "Configures the AVR C++ toolchain distribution.",
    attrs = {
        "distro": attr.string(
            doc = "The name of the AVR toolchain archive.",
            mandatory = False,
            values = AVR_CANONICAL_DISTROS,
        ),
        "custom_archives": attr.string_dict(
            doc = """A mapping of host architecture to custom archive URLs.

This can be used to override the default archive for specific architectures.

Syntax: `<url>[|sha256:<sha256>]`
""",
            mandatory = False,
            default = {},
        ),
    },
)

_rust_toolchain_tag = tag_class(
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
        "src_sha256": attr.string(
            doc = "SHA256 of the rust-src-nightly.tar.xz archive for the given nightly_stamp.",
            default = "",
        ),
        "tools_sha256s": attr.string_dict(
            doc = """SHA256 checksums for nightly Rust host tool archives, all platforms.

Keys are '<stamp>/<archive>' (e.g. '2026-06-18/rustc-nightly-aarch64-apple-darwin.tar.xz').
""",
            default = {},
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

def _avr_cc_toolchain_repos(toolchain_tag, host_key):
    for host in SUPPORTED_HOSTS:
        custom_archive_url = toolchain_tag.custom_archives.get(host, "")
        if custom_archive_url:
            url, sha256 = _parse_url_string(custom_archive_url)
        else:
            if not toolchain_tag.distro:
                fail("No distribution specified for AVR toolchain and no custom archive provided for host '%s'." % host)
            url, sha256 = canonical_archive_url(toolchain_tag.distro, host)

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

def _avr_impl(module_ctx):
    host_key = detect_host_key(module_ctx)
    for mod in module_ctx.modules:
        if not mod.is_root:
            continue

        for tag in mod.tags.cc_toolchain:
            _avr_cc_toolchain_repos(tag, host_key)

        for tag in mod.tags.rust_toolchain:
            avr_rust_toolchains(
                nightly_stamp = tag.nightly_stamp,
                analyzer_version = tag.analyzer_version,
                edition = tag.edition,
                host_key = host_key,
                src_sha256 = tag.src_sha256,
                tools_sha256s = tag.tools_sha256s,
            )

    avr_cc_toolchains()

avr = module_extension(
    implementation = _avr_impl,
    os_dependent = True,
    arch_dependent = True,
    tag_classes = {
        "cc_toolchain": _cc_toolchain_tag,
        "rust_toolchain": _rust_toolchain_tag,
    },
)

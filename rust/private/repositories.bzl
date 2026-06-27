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

"""Repository instantiation for the AVR Rust toolchain."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@rules_rust//rust/private:repositories.bzl", "rust_analyzer_toolchain_tools_repository", "rust_toolchain_tools_repository")
load("//avr:hosts.bzl", "SUPPORTED_HOSTS")

def _avr_rust_toolchains_repo_impl(repository_ctx):
    build_content = repository_ctx.read(
        repository_ctx.path(repository_ctx.attr._build_template),
    )
    repository_ctx.file("BUILD.bazel", build_content)
    repository_ctx.file("WORKSPACE.bazel", "")

_avr_rust_toolchains_repo = repository_rule(
    implementation = _avr_rust_toolchains_repo_impl,
    attrs = {
        "_build_template": attr.label(
            default = "//rust/private:BUILD.toolchains",
            allow_single_file = True,
        ),
    },
)

def _rust_src_repo(nightly_stamp, src_sha256):
    http_archive(
        name = "avr_rust_src",
        build_file = "//rust/private:BUILD.rust_src",
        urls = ["https://static.rust-lang.org/dist/%s/rust-src-nightly.tar.xz" % nightly_stamp],
        sha256 = src_sha256,
        strip_prefix = "rust-src-nightly",
        type = "tar.xz",
    )

def _rust_analyzer_repo(analyzer_version):
    rust_analyzer_toolchain_tools_repository(
        name = "avr_rust_analyzer_tools",
        version = analyzer_version,
    )

def _rust_compiler_repos(nightly_stamp, edition, host_key, tools_sha256s):
    for host in SUPPORTED_HOSTS:
        rust_triple = SUPPORTED_HOSTS[host].rust_triple
        repo_name = SUPPORTED_HOSTS[host].rust_repo.removeprefix("@")
        rust_toolchain_tools_repository(
            name = repo_name,
            exec_triple = rust_triple,
            target_triple = rust_triple,
            version = "nightly/" + nightly_stamp,
            edition = edition,
            rustfmt_version = "nightly/" + nightly_stamp,
            sha256s = tools_sha256s,
        )
        if host == host_key:
            rust_toolchain_tools_repository(
                name = "avr_rust_host_tools",
                exec_triple = rust_triple,
                target_triple = rust_triple,
                version = "nightly/" + nightly_stamp,
                edition = edition,
                rustfmt_version = "nightly/" + nightly_stamp,
                sha256s = tools_sha256s,
            )

def avr_rust_toolchains(nightly_stamp, analyzer_version, edition, host_key, src_sha256, tools_sha256s):
    """Instantiates all repositories needed by the AVR Rust toolchain.

    Args:
        nightly_stamp: The nightly ISO date (YYYY-MM-DD) of the Rust compiler.
        analyzer_version: The version of rust-analyzer to fetch.
        edition: The default Rust edition.
        host_key: The key from SUPPORTED_HOSTS identifying the current host platform.
        src_sha256: SHA256 of the rust-src-nightly.tar.xz archive.
        tools_sha256s: Dict of '<stamp>/<archive>' to sha256 for all host tool archives.
    """
    _rust_src_repo(nightly_stamp, src_sha256)
    _rust_analyzer_repo(analyzer_version)
    _rust_compiler_repos(nightly_stamp, edition, host_key, tools_sha256s)
    _avr_rust_toolchains_repo(name = "avr_rust_toolchains")

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

"""SHA256 checksums for nightly Rust toolchain archives."""

# Maps nightly_stamp → { "rust-src-nightly.tar.xz": sha256,
#                         host_key → { archive_filename: sha256, ... }, ... }
RUST_TOOLS = {
    "2026-03-21": {
        "rust-src-nightly.tar.xz": "7a09bc78a25bcc926584be62cdb362a48dbff1e97b5afc32c84b4380cf9d6289",
        "darwin_arm64": {
            "rustc-nightly-aarch64-apple-darwin.tar.xz": "4be5b7578264d290477d88ff0d2d734d02dc9528dfffe5e4a5e96eed2ba9b650",
            "clippy-nightly-aarch64-apple-darwin.tar.xz": "4b8313af5213eff8fc0822d861df00bdb2949bf4613ff0da5f57e9554acfdc81",
            "cargo-nightly-aarch64-apple-darwin.tar.xz": "c0c14ce10521cc8461eb4b29d7ffbc4e7afc6ff8150ac593caa959d1c978a6c7",
            "llvm-tools-nightly-aarch64-apple-darwin.tar.xz": "9d6d0d8ebaf0b7fe3044b76d9511098ed83813c12e67c1dd9ef9f90442a6e0d5",
            "rust-std-nightly-aarch64-apple-darwin.tar.xz": "60c6e7ff215f29d5b34559a8fe09865740baff077a6166f18048ea36519a3633",
            "rustfmt-nightly-aarch64-apple-darwin.tar.xz": "15c4f81606697c4ba930678494911cbc5814b4155fd943ca9f207b046b1be3b9",
        },
        "linux_arm64": {
            "rustc-nightly-aarch64-unknown-linux-gnu.tar.xz": "216344b66919f9ea9b6918dada87d73a62c733cc301d1e4f9b0046e8833abd0f",
            "clippy-nightly-aarch64-unknown-linux-gnu.tar.xz": "c5acfc6a1270354dce4f522f195cba374d918cd6ebb8ef4d40f88c3d8848179a",
            "cargo-nightly-aarch64-unknown-linux-gnu.tar.xz": "0b52d173eba073775124dc34d70b1bd492785866bb7908a140f6444c794dc51b",
            "llvm-tools-nightly-aarch64-unknown-linux-gnu.tar.xz": "e837b1d055508563cd62764b7187d0a4e4ccc463c4b815ba69dc19e923954f18",
            "rust-std-nightly-aarch64-unknown-linux-gnu.tar.xz": "79b30ad0e7612d10f49ade7ac718e6dffc855d93822d635ca1b22cf314d62c58",
            "rustfmt-nightly-aarch64-unknown-linux-gnu.tar.xz": "aa15466e38634cc2825566a803b1caf54433e7f4ad0635d340915daa11fa7e1a",
        },
        "linux_x86": {
            "rustc-nightly-x86_64-unknown-linux-gnu.tar.xz": "8385d8de2b8fcab5c6f37df1417985e6378cf13548a39521dbfa2cc61b762060",
            "clippy-nightly-x86_64-unknown-linux-gnu.tar.xz": "69910e3bc2dfc641f4c22187364dbc71e6af4c7abc42ea1a0ce3b11759d1bf96",
            "cargo-nightly-x86_64-unknown-linux-gnu.tar.xz": "d8a5ab6599ec16d1641671c45d09c3cbe7d60981b72ff8c836b5899dc391ebd2",
            "llvm-tools-nightly-x86_64-unknown-linux-gnu.tar.xz": "1fe1b4aa1f01be0baf7a52d050129224896f0ed21879c023a898838d45c29c71",
            "rust-std-nightly-x86_64-unknown-linux-gnu.tar.xz": "125b920a4ef38862ddeacc663568b2b0f396524edd481ddbec557a9a0ff5b9c6",
            "rustfmt-nightly-x86_64-unknown-linux-gnu.tar.xz": "ce09aa6d4b1f0b469b95d645d6c74902e1f6ff0b663aa0c3ae689babc2437162",
        },
    },
}

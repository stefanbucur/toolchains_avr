#!/usr/bin/env bash
# Wrapper for the Bazel-managed rust-analyzer binary from @avr_rust_analyzer_tools.
# Auto-fetches the binary on first run if not yet present.
set -euo pipefail
BINARY="$(bazel info output_base)/external/toolchains_avr++avr+avr_rust_analyzer_tools/bin/rust-analyzer"
if [ ! -f "$BINARY" ]; then
    bazel fetch @avr_rust_analyzer_tools//... >&2
fi
exec "$BINARY" "$@"

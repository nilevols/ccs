#!/usr/bin/env bash
#
# ccs installer — copies the `ccs` script to a directory on your PATH.
#
#   ./install.sh                 # install to ~/.local/bin (default)
#   PREFIX=/usr/local ./install.sh   # install to /usr/local/bin (may need sudo)
#
set -eu

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="${PREFIX:+$PREFIX/bin}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

if ! command -v jq >/dev/null 2>&1; then
  echo "warning: 'jq' is not installed — ccs needs it at runtime."
  echo "         https://jqlang.github.io/jq/download/"
fi

mkdir -p "$BIN_DIR"
install -m 0755 "$SRC_DIR/ccs" "$BIN_DIR/ccs"
echo "Installed: $BIN_DIR/ccs"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "note: $BIN_DIR is not on your PATH — add this to your shell rc:"
     echo "      export PATH=\"$BIN_DIR:\$PATH\"" ;;
esac

echo "Done. Run 'ccs' to list your Claude Code sessions."

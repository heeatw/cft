#!/bin/bash
# Symlink bin/cft into ~/.local/bin (or $CFT_BIN_DIR). Re-run after moving the repo.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest_dir="${CFT_BIN_DIR:-$HOME/.local/bin}"
mkdir -p "$dest_dir"
ln -sfn "$here/bin/cft" "$dest_dir/cft"
echo "linked $dest_dir/cft -> $here/bin/cft"
case ":$PATH:" in
  *":$dest_dir:"*) ;;
  *) echo "note: $dest_dir is not on your PATH" ;;
esac
command -v npx >/dev/null || echo "note: npx (Node.js) is needed for \`cft install\`"
echo "next: cft install"

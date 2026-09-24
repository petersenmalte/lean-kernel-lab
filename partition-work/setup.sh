#!/usr/bin/env bash
# Run from any directory. Existing checkouts are verified, never reset.
set -euo pipefail
workspace="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
checkout="$workspace/official/lean-kernel-challenge"
revision=940f0a2ead23ef70ab1387edabb347e629111edd

if [[ ! -d "$checkout" ]]; then
  mkdir -p "$workspace/official"
  git clone https://github.com/SAIRcompetition/lean-kernel-challenge.git "$checkout"
  git -C "$checkout" checkout --detach "$revision"
fi
if [[ "$(git -C "$checkout" rev-parse HEAD)" != "$revision" ]]; then
  echo "Unexpected checkout revision; use the recorded commit in a separate checkout." >&2
  exit 1
fi
if [[ -n "$(git -C "$checkout" status --porcelain --untracked-files=no)" ]]; then
  echo "Official tracked files have changed; restore or inspect them before setup." >&2
  exit 1
fi
if [[ "$(uname -s)" == Darwin ]] && ! command -v gtimeout >/dev/null; then
  echo "Install the documented macOS prerequisite first: brew install coreutils" >&2
  exit 1
fi
elan toolchain install leanprover/lean4:v4.33.1
cd "$checkout"
# This directory is dedicated to managed tools; the upstream setup resets them.
TOOLS_DIR="$workspace/partition-work/tools" bash evaluation/setup.sh --problem partition

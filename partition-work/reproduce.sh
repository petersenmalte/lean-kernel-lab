#!/usr/bin/env bash
set -euo pipefail

workspace="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
candidate="${1:?usage: reproduce.sh /absolute/path/to/Submission.lean LABEL}"
label="${2:?usage: reproduce.sh /absolute/path/to/Submission.lean LABEL}"
python3 "$workspace/partition-work/evaluate.py" \
  --submission "$candidate" \
  --label "$label" \
  --tools-dir "$workspace/partition-work/tools" \
  --evidence-dir "$workspace/partition-work/evidence"

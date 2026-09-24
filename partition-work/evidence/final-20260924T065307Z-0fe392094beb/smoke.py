#!/usr/bin/env python3
"""Independent fixed-package examples and axiom print for this exact artifact."""

import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile


WORKSPACE = Path(__file__).resolve().parents[3]
OFFICIAL = WORKSPACE / "official/lean-kernel-challenge"
PROBLEM = OFFICIAL / "problems/partition"
SUBMISSION = WORKSPACE / "partition/Submission.lean"
SMOKE = WORKSPACE / "partition-work/checks/Smoke.lean"
HERE = Path(__file__).resolve().parent
EXPECTED_SHA = "0fe392094beb40ce1672defec11443d58a5466605ebc0e283b39cf7cd752f575"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def logged(command, cwd, name):
    with (HERE / name).open("wb") as stream:
        return subprocess.run(command, cwd=cwd, stdout=stream, stderr=subprocess.STDOUT).returncode


assert digest(SUBMISSION) == EXPECTED_SHA
fixed_hashes = {name: digest(PROBLEM / name)
                for name in ("Spec.lean", "lakefile.toml", "lean-toolchain")}
with tempfile.TemporaryDirectory(prefix="lkc-partition-final-smoke-") as folder:
    package = Path(folder)
    for name in fixed_hashes:
        shutil.copy2(PROBLEM / name, package / name)
    shutil.copy2(SUBMISSION, package / "Submission.lean")
    shutil.copy2(SMOKE, package / "Smoke.lean")
    assert digest(package / "Submission.lean") == EXPECTED_SHA
    assert all(digest(package / name) == value for name, value in fixed_hashes.items())
    build_exit = logged(["lake", "build"], package, "smoke-build.log")
    lean_exit = logged(["lake", "env", "lean", "Smoke.lean"], package, "smoke-lean.log")
    results = {
        "submission_sha256": EXPECTED_SHA,
        "smoke_sha256": digest(SMOKE),
        "official_problem_files_sha256": fixed_hashes,
        "commands": ["lake build", "lake env lean Smoke.lean"],
        "build_exit": build_exit,
        "lean_exit": lean_exit,
        "source_unchanged": digest(SUBMISSION) == EXPECTED_SHA,
    }
    (HERE / "smoke-result.json").write_text(json.dumps(results, indent=2) + "\n")
    print(json.dumps(results, indent=2))
    if build_exit or lean_exit or not results["source_unchanged"]:
        raise SystemExit(1)

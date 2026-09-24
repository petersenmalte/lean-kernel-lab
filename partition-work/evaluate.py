#!/usr/bin/env python3
"""Reproduce a partition build and the pinned local judge, preserving raw evidence.

The judge is the authority for interface, axiom, universal-proof, and case checks.
This wrapper runs one candidate at a time and never edits its source or the
official problem/evaluator files.
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import tempfile
import time


WORKSPACE = Path(__file__).resolve().parents[1]
OFFICIAL = WORKSPACE / "official/lean-kernel-challenge"
PROBLEM = OFFICIAL / "problems/partition"
EXPECTED_COMMIT = "940f0a2ead23ef70ab1387edabb347e629111edd"
EXPECTED_TOOLCHAIN = "leanprover/lean4:v4.33.1"
EXPECTED_CASES = (14, 18, 22, 26, 32, 36)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def capture(args: list[str], cwd: Path) -> str:
    return subprocess.check_output(args, cwd=cwd, text=True, stderr=subprocess.STDOUT).strip()


def run_logged(args: list[str], cwd: Path, env: dict[str, str], log: Path) -> dict:
    started = time.monotonic()
    with log.open("wb") as stream:
        process = subprocess.run(args, cwd=cwd, env=env, stdout=stream, stderr=subprocess.STDOUT)
    return {"command": args, "cwd": str(cwd), "exit_code": process.returncode,
            "elapsed_wall_s": round(time.monotonic() - started, 3), "log": str(log)}


def summarize(verdict: dict) -> dict:
    stages = verdict.get("stages", {})
    report = verdict.get("replay_report") or {}
    timing = verdict.get("timing") or {}
    cases = []
    for row in timing.get("scaling", []):
        cases.append({"slot": row.get("slot"), "group": row.get("group"),
                      "n": row.get("n"), "result": row.get("result"),
                      "median_wall_s": row.get("median_s"),
                      "reason": row.get("reason")})
    return {
        "verdict": verdict.get("status"), "reason": verdict.get("reason"),
        "metric": verdict.get("metric"), "protocol": verdict.get("timing_protocol"),
        "comparator_exit": (stages.get("comparator") or {}).get("exit"),
        "axiom_audit_exit": (stages.get("axioms") or {}).get("exit"),
        "correctness_replay": report.get("correctness"),
        "computation_total_wall_s": report.get("computation_total"),
        "complete": report.get("eligible"), "cases": cases,
        "all_expected_cases_reported": tuple(row["n"] for row in cases) == EXPECTED_CASES,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--submission", required=True, type=Path)
    parser.add_argument("--label", required=True)
    parser.add_argument("--tools-dir", type=Path,
                        default=WORKSPACE / "partition-work/tools")
    parser.add_argument("--evidence-dir", type=Path,
                        default=WORKSPACE / "partition-work/evidence")
    args = parser.parse_args()
    source = args.submission.resolve(strict=True)
    if source.name != "Submission.lean" or not source.is_file():
        parser.error("--submission must name an existing regular Submission.lean")
    if not args.label.replace("-", "").replace("_", "").isalnum():
        parser.error("--label must be alphanumeric with optional '-' or '_'")

    revision = capture(["git", "rev-parse", "HEAD"], OFFICIAL)
    toolchain = (PROBLEM / "lean-toolchain").read_text().strip()
    if revision != EXPECTED_COMMIT or toolchain != EXPECTED_TOOLCHAIN:
        parser.error(f"unexpected official revision/toolchain: {revision} / {toolchain}")
    forbidden = ("PERF_COUNT", "PERF_SEED", "OFFICIAL_EVAL", "EVALUATION_COHORT",
                 "TIMING_METRIC", "TIMING_EXECUTOR_URLS", "TIMING_TIMEOUT_SECONDS",
                 "DEFER_TIMING")
    active = [key for key in forbidden if os.environ.get(key)]
    if active:
        parser.error(f"unset local-evaluator policy overrides: {', '.join(active)}")

    tools_dir = args.tools_dir.resolve()
    comparator = tools_dir / "comparator/.lake/build/bin/comparator"
    exporter_dir = tools_dir / "lean4export/.lake/build/bin"
    exporter = exporter_dir / "lean4export"
    timer = OFFICIAL / "evaluation/judge/timer-kernel/.lake/build/bin/kernel"
    missing = [str(path) for path in (comparator, exporter, timer) if not path.is_file()]
    if missing:
        parser.error(f"evaluator setup incomplete: {', '.join(missing)}")

    source_digest = sha256(source)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    output_dir = args.evidence_dir.resolve() / f"{args.label}-{stamp}-{source_digest[:12]}"
    output_dir.mkdir(parents=True, exist_ok=False)
    env = os.environ.copy()
    env.update(COMPARATOR_BIN=str(comparator), LEAN4EXPORT_BIN=str(exporter_dir),
               TIMER_BIN=str(timer))
    metadata = {
        "label": args.label, "source": str(source), "source_sha256": source_digest,
        "official_checkout": str(OFFICIAL), "official_commit": revision,
        "lean_toolchain": toolchain, "spec_sha256": sha256(PROBLEM / "Spec.lean"),
        "official_evaluator_sha256": sha256(OFFICIAL / "evaluation/run.py"),
        "partition_config_sha256": sha256(OFFICIAL / "evaluation/problems/partition/config.json"),
        "tool_revisions": {
            "comparator": capture(["git", "rev-parse", "HEAD"], tools_dir / "comparator"),
            "lean4export": capture(["git", "rev-parse", "HEAD"], tools_dir / "lean4export"),
        },
        "host": {"platform": platform.platform(), "machine": platform.machine(),
                 "python": platform.python_version()},
        "metric": "wall_time", "plan": list(EXPECTED_CASES), "local_timeout_s": 120,
        "tool_paths": {"comparator": str(comparator), "lean4export": str(exporter),
                       "timer": str(timer)},
    }
    (output_dir / "metadata.json").write_text(json.dumps(metadata, indent=2) + "\n")
    print(f"Evidence directory: {output_dir}", flush=True)

    # Use a disposable participant package for the independent compiler check.
    # The local judge later assembles its own locked evaluation package.
    with tempfile.TemporaryDirectory(prefix="lkc-partition-build-") as temp:
        build_dir = Path(temp)
        for name in ("Spec.lean", "lakefile.toml", "lean-toolchain"):
            shutil.copy2(PROBLEM / name, build_dir / name)
        shutil.copy2(source, build_dir / "Submission.lean")
        lean_version = capture(["lake", "env", "lean", "--version"], build_dir)
        metadata["lean_version"] = lean_version
        (output_dir / "metadata.json").write_text(json.dumps(metadata, indent=2) + "\n")
        print("Compiling disposable participant package...", flush=True)
        build = run_logged(["lake", "build"], build_dir, env, output_dir / "build.log")
    (output_dir / "build.json").write_text(json.dumps(build, indent=2) + "\n")

    print("Running the complete pinned local evaluator...", flush=True)
    command = [sys.executable, "evaluation/run.py", "--problem", "partition",
               "--submission", str(source), "--timeout", "120"]
    evaluator_started_at = time.time()
    evaluation = run_logged(command, OFFICIAL, env, output_dir / "evaluation.log")
    token = hashlib.sha256(str(source).encode()).hexdigest()[:16]
    result_path = OFFICIAL / "results/local-evaluation/partition" / f"{token}.json"
    verdict = None
    if result_path.is_file() and result_path.stat().st_mtime >= evaluator_started_at:
        verdict = json.loads(result_path.read_text())
        (output_dir / "verdict.json").write_text(json.dumps(verdict, indent=2) + "\n")
    evaluation["official_result_path"] = str(result_path)
    (output_dir / "evaluation.json").write_text(json.dumps(evaluation, indent=2) + "\n")

    summary = {"compilation": {"passed": build["exit_code"] == 0, **build},
               "evaluation": evaluation,
               "source_unchanged": sha256(source) == source_digest,
               "result": summarize(verdict) if verdict is not None else None}
    (output_dir / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    print(json.dumps({"output_dir": str(output_dir), "compilation_passed":
                      summary["compilation"]["passed"], "evaluation_exit":
                      evaluation["exit_code"], "source_unchanged": summary["source_unchanged"],
                      "result": summary["result"]}, indent=2), flush=True)
    return 0 if (build["exit_code"] == 0 and evaluation["exit_code"] == 0
                 and summary["source_unchanged"] and summary["result"]
                 and summary["result"]["verdict"] == "accepted"
                 and summary["result"]["complete"]) else 1


if __name__ == "__main__":
    raise SystemExit(main())

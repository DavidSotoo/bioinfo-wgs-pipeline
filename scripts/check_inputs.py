#!/usr/bin/env python3
"""Validate configured sample, unit, FASTQ, and reference inputs."""

from __future__ import annotations

import csv
import sys
from pathlib import Path

import yaml


def read_tsv(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def main() -> int:
    config_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("config/config.yaml")
    config = yaml.safe_load(config_path.read_text(encoding="utf-8"))

    samples_path = Path(config["samples_tsv"])
    units_path = Path(config["units_tsv"])
    required = [Path(config["reference"]), samples_path, units_path]

    samples = {row["sample"] for row in read_tsv(samples_path)}
    units = read_tsv(units_path)

    unknown_samples = sorted({row["sample"] for row in units} - samples)
    if unknown_samples:
        print("Units reference samples missing from samples.tsv:", file=sys.stderr)
        for sample in unknown_samples:
            print(f"  - {sample}", file=sys.stderr)
        return 1

    for row in units:
        required.extend([Path(row["fq1"]), Path(row["fq2"])])

    missing = [str(path) for path in required if not path.exists()]
    if missing:
        print("Missing required input files:", file=sys.stderr)
        for path in missing:
            print(f"  - {path}", file=sys.stderr)
        print("\nCreate the bundled mini dataset with:", file=sys.stderr)
        print("  bash scripts/create_test_fastqs.sh", file=sys.stderr)
        return 1

    print(f"All inputs are present: {len(samples)} samples and {len(units)} paired-end units.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

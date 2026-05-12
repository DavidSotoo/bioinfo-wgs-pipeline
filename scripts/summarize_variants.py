#!/usr/bin/env python3
"""Create a small TSV summary from a VCF/BCF file."""

from __future__ import annotations

import sys
from pathlib import Path

import pysam


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: summarize_variants.py <input.vcf.gz> <output.tsv>", file=sys.stderr)
        return 2

    input_vcf = Path(sys.argv[1])
    output_tsv = Path(sys.argv[2])
    output_tsv.parent.mkdir(parents=True, exist_ok=True)

    with pysam.VariantFile(str(input_vcf)) as vcf, output_tsv.open("w", encoding="utf-8") as out:
        out.write("chrom\tpos\tref\talt\tqual\tfilter\tsamples\n")
        for record in vcf:
            alts = ",".join(record.alts or ["."])
            filters = ";".join(record.filter.keys()) if record.filter.keys() else "PASS"
            samples = ",".join(record.samples.keys())
            qual = "." if record.qual is None else f"{record.qual:.2f}"
            out.write(f"{record.chrom}\t{record.pos}\t{record.ref}\t{alts}\t{qual}\t{filters}\t{samples}\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

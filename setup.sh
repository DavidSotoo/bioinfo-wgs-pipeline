#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_DIR}"

echo "[wgs-pipeline] Preparing reproducible WGS Snakemake project"

if ! command -v conda >/dev/null 2>&1; then
  echo "[wgs-pipeline] Conda was not found."
  echo "Install Miniconda or Mambaforge first, then re-run:"
  echo "  https://docs.conda.io/en/latest/miniconda.html"
  exit 1
fi

if command -v git >/dev/null 2>&1; then
  git config --global --add safe.directory "${PROJECT_DIR}" || true
fi

conda env create -f envs/snakemake.yaml || conda env update -f envs/snakemake.yaml --prune

bash scripts/create_test_fastqs.sh

echo
echo "[wgs-pipeline] Base environment is ready."
echo "Activate it with:"
echo "  conda activate wgs-pipeline"
echo
echo "Validate inputs:"
echo "  python scripts/check_inputs.py"
echo
echo "Dry-run:"
echo "  snakemake -np --use-conda"
echo
echo "Run the complete workflow:"
echo "  snakemake --cores 4 --use-conda"
echo
echo "Generate only the DAG:"
echo "  snakemake --cores 1 --use-conda results/dag/dag.png"

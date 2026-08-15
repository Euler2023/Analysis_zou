#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p build/tex
python3 scripts/audit_ocr.py
if [[ "${REGENERATE_TEX:-0}" == "1" ]]; then
  python3 scripts/convert.py
fi
latexmk -xelatex -halt-on-error -interaction=nonstopmode \
  -auxdir=build -outdir=. main_driver.tex

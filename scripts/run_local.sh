#!/usr/bin/env bash
# Run the whole pipeline locally (Linux / macOS / WSL / Git Bash).
# Run from the repository root:  bash scripts/run_local.sh
set -euo pipefail

python3 -m venv .venv
source .venv/bin/activate 2>/dev/null || source .venv/Scripts/activate
python -m pip install --upgrade pip
pip install -r requirements.txt

echo "== Practical 2: train =="        && python train_model.py
echo "== Practical 3: quality gate ==" && python quality_gate.py
echo "== Practical 2: ML tests =="     && python -m unittest test_ml_pipeline.py -v
echo "== Practical 5: API tests =="    && python -m unittest test_app.py -v
echo
echo "All local checks passed. Start the API with:  python app.py"

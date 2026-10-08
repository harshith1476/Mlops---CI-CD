# Run the whole pipeline locally (Windows PowerShell).
# Run from the repository root:  .\scripts\run_local.ps1
$ErrorActionPreference = "Stop"

python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt

Write-Host "== Practical 2: train ==";        python train_model.py;                          if ($LASTEXITCODE) { exit 1 }
Write-Host "== Practical 3: quality gate =="; python quality_gate.py;                         if ($LASTEXITCODE) { exit 1 }
Write-Host "== Practical 2: ML tests ==";     python -m unittest test_ml_pipeline.py -v;      if ($LASTEXITCODE) { exit 1 }
Write-Host "== Practical 5: API tests ==";    python -m unittest test_app.py -v;              if ($LASTEXITCODE) { exit 1 }

Write-Host "`nAll local checks passed. Start the API with:  python app.py"

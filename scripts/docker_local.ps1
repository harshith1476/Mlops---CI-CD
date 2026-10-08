# Practical 6 (Windows PowerShell): build + run + test the Docker image locally.
# Needs Docker Desktop running. Run from the repository root.
$ErrorActionPreference = "Stop"

if (-not (Test-Path student_result_model.pkl)) { python train_model.py }

docker build -t student-result-ml:1.0 .
docker rm -f student-result-ml-container 2>$null
docker run -d --name student-result-ml-container -p 5000:5000 student-result-ml:1.0
Start-Sleep -Seconds 5

Invoke-RestMethod http://localhost:5000/health

$pass = @{ attendance = 90; internal_marks = 85; assignment_marks = 88; previous_score = 80 } | ConvertTo-Json
Invoke-RestMethod -Uri http://localhost:5000/predict -Method Post -ContentType "application/json" -Body $pass

$fail = @{ attendance = 55; internal_marks = 30; assignment_marks = 40; previous_score = 35 } | ConvertTo-Json
Invoke-RestMethod -Uri http://localhost:5000/predict -Method Post -ContentType "application/json" -Body $fail

docker logs student-result-ml-container
Write-Host "Stop with: docker stop student-result-ml-container; docker rm student-result-ml-container"

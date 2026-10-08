#!/usr/bin/env bash
# Practical 6: build + run + test the Docker image locally.
# Needs Docker running and a trained model (run train_model.py first).
# Run from the repository root:  bash scripts/docker_local.sh
set -euo pipefail

[ -f student_result_model.pkl ] || python train_model.py

docker build -t student-result-ml:1.0 .
docker rm -f student-result-ml-container >/dev/null 2>&1 || true
docker run -d --name student-result-ml-container -p 5000:5000 student-result-ml:1.0

for i in $(seq 1 15); do
  curl --fail --silent http://localhost:5000/health && break
  echo "waiting... $i"; sleep 2
done
echo
echo "PASS sample:"
curl -s -X POST http://localhost:5000/predict -H "Content-Type: application/json" \
  -d '{"attendance":90,"internal_marks":85,"assignment_marks":88,"previous_score":80}'
echo
echo "FAIL sample:"
curl -s -X POST http://localhost:5000/predict -H "Content-Type: application/json" \
  -d '{"attendance":55,"internal_marks":30,"assignment_marks":40,"previous_score":35}'
echo
docker logs student-result-ml-container
echo "Stop with: docker stop student-result-ml-container && docker rm student-result-ml-container"

"""
Controlled-failure helper for Practicals 2, 3, 4, 5 and 7.

Usage (run from the repository root):
    python scripts/failure_demo.py break   p3
    python scripts/failure_demo.py restore p3

Each call edits ONE file, commits with the message from the practical
and pushes to origin/main (GitHub Actions then runs automatically).
Add --no-push to only commit locally.
"""
import subprocess
import sys
from pathlib import Path

DEMOS = {
    "p2": {
        "file": "test_ml_pipeline.py",
        "good": "self.assertEqual(int(prediction), 1)",
        "bad": "self.assertEqual(int(prediction), 0)  # DEMO_FAILURE",
        "break_msg": "Introduce test failure for CI demonstration",
        "restore_msg": "Fix ML prediction test",
    },
    "p3": {
        "file": "quality_gate.py",
        "good": "MINIMUM_ACCURACY = 0.85",
        "bad": "MINIMUM_ACCURACY = 0.99",
        "break_msg": "Increase threshold for quality gate failure demo",
        "restore_msg": "Restore ML quality gate threshold",
    },
    "p4": {
        "file": ".github/workflows/ml-ci.yml",
        "good": "            student_result_model.pkl\n            metrics.json",
        "bad": "            student_result_model_missing.pkl\n            metrics.json",
        "break_msg": "Demonstrate missing artifact failure",
        "restore_msg": "Restore ML artifact path",
    },
    "p5": {
        "file": "test_app.py",
        "good": '            response.get_json()["prediction"],\n            "PASS"',
        "bad": '            response.get_json()["prediction"],\n            "FAIL"  # DEMO_FAILURE',
        "break_msg": "Demonstrate application test failure",
        "restore_msg": "Restore valid prediction API test",
    },
    "p7": {
        "file": ".github/workflows/ml-ci.yml",
        "good": "http://localhost:5000/health; then",
        "bad": "http://localhost:5001/health; then",
        "break_msg": "Demonstrate Docker health check failure",
        "restore_msg": "Restore Docker health check port",
    },
}


def run(*cmd):
    print("$", " ".join(cmd))
    subprocess.run(cmd, check=True)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    push = "--no-push" not in sys.argv
    if len(args) != 2 or args[0] not in ("break", "restore") or args[1] not in DEMOS:
        print(__doc__)
        print("Demos:", ", ".join(DEMOS))
        sys.exit(1)

    action, key = args
    demo = DEMOS[key]
    path = Path(demo["file"])
    text = path.read_text(encoding="utf-8")

    old, new = (demo["good"], demo["bad"]) if action == "break" else (demo["bad"], demo["good"])
    if text.count(old) != 1:
        sys.exit(f"Expected exactly one match for the text to change in {path}, "
                 f"found {text.count(old)}. Is it already {'broken' if action == 'break' else 'restored'}?")

    path.write_text(text.replace(old, new), encoding="utf-8")
    run("git", "add", str(path))
    run("git", "commit", "-m", demo[f"{action}_msg"])
    if push:
        run("git", "push", "origin", "main")
    print(f"\n{action.upper()} {key} done. Open GitHub -> Actions to watch the run.")


if __name__ == "__main__":
    main()

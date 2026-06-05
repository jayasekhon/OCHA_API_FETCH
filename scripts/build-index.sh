#!/usr/bin/env bash
# Rebuilds data/index.json — a map of all available datasets and their files
set -e

INDEX_FILE="data/index.json"

echo "Rebuilding ${INDEX_FILE}..."

python3 - << 'PYEOF'
import os, json
from datetime import datetime

base = "data"
index = {}

for slug in sorted(os.listdir(base)):
    slug_path = os.path.join(base, slug)
    if not os.path.isdir(slug_path):
        continue
    files = sorted(
        f for f in os.listdir(slug_path)
        if not f.startswith("latest") and not f.startswith(".")
    )
    if not files:
        continue
    index[slug] = {
        "latest": f"{slug}/latest.{files[-1].split('.')[-1]}",
        "files": [f"{slug}/{f}" for f in files],
        "updated": files[-1].replace(".json","").replace(".xml","")
    }

with open(os.path.join(base, "index.json"), "w") as f:
    json.dump({"generated": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"), "datasets": index}, f, indent=2)

print(f"Index written — {len(index)} dataset(s) found")
PYEOF

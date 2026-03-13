#!/usr/bin/env bash
set -euo pipefail

PACKAGE_FILE="package.json"

if [[ ! -f "$PACKAGE_FILE" ]]; then
  echo "Error: package.json not found"
  exit 1
fi

current_version=$(python3 - <<'PY'
import json
with open("package.json") as f:
    print(json.load(f)["version"])
PY
)

clean_version="${current_version%%-*}"

if [[ ! "$clean_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: invalid clean version derived from $current_version"
  exit 1
fi

python3 - <<PY
import json
package_file = "package.json"
with open(package_file) as f:
    data = json.load(f)
data["version"] = "${clean_version}"
with open(package_file, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY

echo "Release version normalized: ${current_version} -> ${clean_version}"
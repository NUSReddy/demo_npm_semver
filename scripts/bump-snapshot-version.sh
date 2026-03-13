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

if [[ "$current_version" =~ ^([0-9]+\.[0-9]+\.[0-9]+)-([0-9]+)$ ]]; then
  base_version="${BASH_REMATCH[1]}"
  snapshot_number="${BASH_REMATCH[2]}"
  next_snapshot=$((snapshot_number + 1))
elif [[ "$current_version" =~ ^([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
  base_version="${BASH_REMATCH[1]}"
  next_snapshot=1
else
  echo "Error: invalid version format in package.json: $current_version"
  exit 1
fi

new_version="${base_version}-${next_snapshot}"

python3 - <<PY
import json
package_file = "package.json"
with open(package_file) as f:
    data = json.load(f)
data["version"] = "${new_version}"
with open(package_file, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY

echo "Snapshot version updated: ${current_version} -> ${new_version}"
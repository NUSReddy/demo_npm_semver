#!/usr/bin/env bash
set -euo pipefail

MAIN_BRANCH="main"
PACKAGE_FILE="package.json"

get_current_branch() {
  if [[ -n "${GITHUB_HEAD_REF:-}" ]]; then
    echo "${GITHUB_HEAD_REF}"
  elif [[ -n "${GITHUB_REF_NAME:-}" ]]; then
    echo "${GITHUB_REF_NAME}"
  else
    git rev-parse --abbrev-ref HEAD
  fi
}

read_local_version() {
  python3 - <<'PY'
import json
with open("package.json") as f:
    print(json.load(f)["version"])
PY
}

read_git_ref_version() {
  local git_ref="$1"
  git show "${git_ref}:package.json" 2>/dev/null | python3 -c 'import sys, json; print(json.load(sys.stdin)["version"])'
}

normalize_version() {
  local version="$1"
  echo "${version%%-*}"
}

is_clean_semver() {
  local version="$1"
  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

version_greater_than() {
  local left="$1"
  local right="$2"
  python3 - "$left" "$right" <<'PY'
import sys
def parse(v):
    return tuple(map(int, v.split(".")))
print("true" if parse(sys.argv[1]) > parse(sys.argv[2]) else "false")
PY
}

if [[ ! -f "$PACKAGE_FILE" ]]; then
  echo "Error: package.json not found"
  exit 1
fi

current_branch="$(get_current_branch)"

if [[ "$current_branch" == "$MAIN_BRANCH" ]]; then
  echo "Skipping feature validation on main"
  exit 0
fi

case "$current_branch" in
  feature/*)
    ;;
  *)
    echo "Skipping validation for non-feature branch: $current_branch"
    exit 0
    ;;
esac

git fetch origin "+refs/heads/*:refs/remotes/origin/*" >/dev/null 2>&1 || true

branch_version_raw="$(read_local_version)"
branch_version="$(normalize_version "$branch_version_raw")"

if ! is_clean_semver "$branch_version"; then
  echo "Error: feature branch must start with a clean semver version like 1.2.2"
  echo "Found: $branch_version_raw"
  exit 1
fi

main_version_raw="$(read_git_ref_version "origin/${MAIN_BRANCH}")"
main_version="$(normalize_version "$main_version_raw")"

if ! is_clean_semver "$main_version"; then
  echo "Error: invalid main version: $main_version_raw"
  exit 1
fi

if [[ "$(version_greater_than "$branch_version" "$main_version")" != "true" ]]; then
  echo "Error: feature branch version must be greater than main version"
  echo "Main version   : $main_version"
  echo "Branch version : $branch_version"
  exit 1
fi

while IFS= read -r remote_ref; do
  remote_branch="${remote_ref#origin/}"

  [[ "$remote_branch" == "$MAIN_BRANCH" ]] && continue
  [[ "$remote_branch" == "$current_branch" ]] && continue

  case "$remote_branch" in
    feature/*)
      ;;
    *)
      continue
      ;;
  esac

  other_version_raw="$(read_git_ref_version "$remote_ref" || true)"
  [[ -z "${other_version_raw:-}" ]] && continue

  other_version="$(normalize_version "$other_version_raw")"

  if [[ "$other_version" == "$branch_version" ]]; then
    echo "Error: version ${branch_version} is already reserved by remote branch ${remote_branch}"
    echo "Please choose another release version in package.json"
    exit 1
  fi
done < <(git for-each-ref --format='%(refname:short)' refs/remotes/origin)

echo "Feature version validation passed"
echo "Main version   : $main_version"
echo "Branch version : $branch_version"
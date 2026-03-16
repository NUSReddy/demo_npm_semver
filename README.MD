# Demo NPM Semantic Version

This repository demonstrates a **semantic version workflow for Node.js projects** using **GitHub Actions**, **feature branches**, and **snapshot versions**.

The workflow automatically:

- Creates **snapshot versions on feature branches**
- Converts snapshots to **clean release versions on `main`**
- Creates **Git tags automatically**
- Ensures **consistent semantic versioning**
- Prevents developers from accidentally releasing duplicate versions

---

# Overview

The system implements a **CI-driven semantic versioning strategy** where:

| Branch Type | Version Format | Example |
|---|---|---|
| `feature/*` | Snapshot version | `1.2.0-1`, `1.2.0-2` |
| `main` | Release version | `1.2.0` |
| Git Tag | Release tag | `v1.2.0` |

---

# Repository Features

## Automatic Snapshot Versioning

Feature branches automatically increment snapshot versions.

Example progression on a feature branch:

```
1.2.0-1
1.2.0-2
1.2.0-3
```

These snapshots are generated automatically by the CI pipeline.

---

## Automatic Release Version Normalization

When a feature branch is merged to `main`:

```
1.2.0-3 → 1.2.0
```

The snapshot suffix is removed and committed automatically.

Commit example:

```
chore: normalize release version 1.2.0 [skip ci]
```

---

## Automatic Git Tag Creation

After normalization, the pipeline creates a Git tag.

Example:

```
v1.2.0
```

This tag is pushed automatically.

---

## Version Ahead Protection

This validation runs in both workflows as a safeguard at two stages. The feature build workflow validates that the feature branch version is strictly greater than the current `main` version before allowing the build to proceed. The main release workflow additionally validates that the incoming version is not behind the latest tagged release before normalizing and tagging. This prevents stale feature branches from merging into `main` with an older version, even if branch protection rules are bypassed.

For example, if `main` is already at `1.3.5` (after a previous feature merge) and a feature branch has version `1.3.4-10`, the CI build will fail with:

```
Error: feature branch version must be greater than main version
Main version   : 1.3.5
Branch version : 1.3.4
```

The feature branch must update `package.json` to a version higher than `main` before it can be merged.

---

## Duplicate Version Protection

The workflow prevents duplicate releases.

If a tag already exists:

```
v1.2.0 already exists
```

the workflow will skip tag creation.

---

# Branch Strategy

## Main Branch

`main` represents **stable releases**.

Rules:

- Only merged pull requests allowed
- Release versions only
- Git tags created automatically

Example history:

```
Merge PR feature/notification
chore: normalize release version 1.2.0
tag: v1.2.0
```

---

## Feature Branches

All development must occur in feature branches.

Required naming pattern:

```
feature/<name>
```

Examples:

```
feature/login
feature/notification
feature/user-profile
```

Branches **must start with `feature/`** for the workflow to work correctly.

---

# Versioning Rules

This repository follows **Semantic Versioning**.

```
MAJOR.MINOR.PATCH
```

Example:

```
1.2.0
```

| Change | Version Bump |
|---|---|
Breaking changes | MAJOR |
New features | MINOR |
Bug fixes | PATCH |

---

# Developer Workflow

## Step 1 — Create Feature Branch

Developers create a branch from `main`.

Example:

```bash
git checkout main
git pull
git checkout -b feature/notification
```

---

## Step 2 — Update Version (Developer Decision)

Developers update `package.json` based on the change.

Example:

```
1.1.0 → 1.2.0
```

Commit:

```
feat: add notification service
```

---

## Step 3 — Push Feature Branch

```bash
git push origin feature/notification
```

The CI pipeline will:

1. Detect feature branch
2. Generate snapshot version

Example:

```
1.2.0-1
```

Commit created automatically:

```
chore: snapshot version 1.2.0-1 [skip ci]
```

---

## Step 4 — Additional Commits

Every new commit triggers another snapshot.

Example progression:

```
1.2.0-1
1.2.0-2
1.2.0-3
```

Commit examples:

```
chore: snapshot version 1.2.0-2 [skip ci]
chore: snapshot version 1.2.0-3 [skip ci]
```

---

## Step 5 — Create Pull Request

Create PR:

```
feature/notification → main
```

---

## Step 6 — Merge Pull Request

Once merged:

The **main release workflow runs**.

Actions performed:

1. Remove snapshot suffix

```
1.2.0-3 → 1.2.0
```

2. Commit normalized version

```
chore: normalize release version 1.2.0 [skip ci]
```

3. Create Git tag

```
v1.2.0
```

---

# Example End-to-End Workflow

## Developer Flow

```
main: 1.1.0
```

Create branch:

```
feature/notification
```

Update version:

```
1.2.0
```

Push branch.

---

## CI Snapshot Builds

```
commit 1 → 1.2.0-1
commit 2 → 1.2.0-2
commit 3 → 1.2.0-3
```

---

## Merge to Main

Pipeline executes:

```
1.2.0-3 → 1.2.0
```

Commit created:

```
chore: normalize release version 1.2.0 [skip ci]
```

Tag created:

```
v1.2.0
```

---

# Commit History Example

```
feat: add notification service
chore: snapshot version 1.2.0-1
chore: snapshot version 1.2.0-2
chore: snapshot version 1.2.0-3

Merge pull request #5 from feature/notification

chore: normalize release version 1.2.0 [skip ci]
```

Tag:

```
v1.2.0
```

---

# GitHub Actions Workflows

## Feature Build Workflow (`feature-build.yml`)

Triggers on pushes to `feature/**` branches.

Responsibilities:

1. Validate the feature branch version is greater than `main` and not reserved by another branch
2. Install dependencies, build, and run tests
3. Bump the snapshot version
4. Commit and push the snapshot version

Example commit:

```
chore: snapshot version 1.2.0-2 [skip ci]
```

---

## Main Release Workflow (`main-release.yml`)

Triggers on pushes to `main`.

Responsibilities:

1. Validate that the incoming version is not behind the latest tagged release
2. Strip the snapshot suffix to normalize the release version
3. Commit the normalized version if changed
4. Install dependencies, build, and run tests
5. Create and push a git tag (e.g. `v1.2.0`) if it doesn't already exist

Example commit:

```
chore: normalize release version 1.2.0 [skip ci]
```

---

# Project Structure

```
.
├── .github
│   └── workflows
│       ├── feature-build.yml
│       └── main-release.yml
│
├── scripts
│   ├── bump-snapshot-version.sh
│   ├── strip-snapshot-version.sh
│   └── validate-feature-version.sh
│
├── src
│   └── index.js
│
├── test
│   └── version.test.js
│
├── package.json
└── README.MD
```

---

# Scripts

## validate-feature-version.sh

Validates the feature branch version before building. Ensures the version is a clean semver, is greater than `main`, and is not already reserved by another feature branch.

```bash
bash scripts/validate-feature-version.sh
```

---

## bump-snapshot-version.sh

Increments the snapshot version suffix, or adds `-1` if no snapshot suffix exists.

Example:

```
1.2.0 → 1.2.0-1
1.2.0-1 → 1.2.0-2
```

```bash
bash scripts/bump-snapshot-version.sh
```

---

## strip-snapshot-version.sh

Removes the snapshot suffix to produce a clean release version.

Example:

```
1.2.0-3 → 1.2.0
```

```bash
bash scripts/strip-snapshot-version.sh
```

---

# Running Locally

Install dependencies:

```bash
npm install
```

Run build:

```bash
npm run build
```

Run tests:

```bash
npm test
```

---

# Versioning Example

| Stage | Version |
|---|---|
Developer bump | `1.2.0` |
First feature build | `1.2.0-1` |
Second build | `1.2.0-2` |
Merge to main | `1.2.0` |
Git Tag | `v1.2.0` |

---

# Benefits

## Simplified Branch Strategy

This approach uses only `feature/*` branches and `main`, removing the need for long-lived branches such as `develop`, `release`, `uat`, or `staging`. Multiple environment branches often lead to branch drift, repeated merge conflicts, confusion about which branch reflects the true release state, and harder rollback management. With this model, `main` is the single source of truth for releases, and Git tags on `main` are promoted across all environments.

## Release and Backout Manifest Support

Version tags make it straightforward to maintain release manifests and backout manifests for deployments.

Example release manifest:

```
notification-service = v1.2.0
auth-service    = v3.4.1
order-service   = v2.1.5
```

Example backout manifest:

```
notification-service = v1.1.8
auth-service    = v3.4.0
order-service   = v2.1.4
```

Without proper version tagging, it becomes difficult to know exactly which code was released and what version should be rolled back.

## Main Branch Protection

The `main` branch must be protected with branch protection rules. Direct pushes and force pushes should be disabled. All changes to `main` must go through a pull request (merge request) with at least one approval. This ensures that every release version on `main` has been reviewed and approved, maintaining a trustworthy release history and preventing accidental overwrites of tagged releases.

## One Main Branch for All Environments

Instead of separate environment branches, teams map environments to specific tags from `main`:

| Environment | Deployed Version |
|---|---|
| DEV | `v1.3.0` |
| SIT | `v1.2.1` |
| STG | `v1.2.0` |
| PROD | `v1.2.0` |

The same tagged artifact is promoted across environments rather than rebuilding from different branches.

## Additional Benefits

- Automated semantic versioning with no manual version mistakes
- Consistent Git tags for productionised releases
- Lower-environment deployments from feature branch snapshots
- Reliable rollback to a previously known stable tag
- Better auditability and traceability (what was deployed, when, and what changes are included)
- Cleaner Git history and reduced merge complexity
- Clear traceability from feature → release

---

# License

MIT License
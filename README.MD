# Demo NPM Semantic Version Automation

This repository demonstrates a **fully automated semantic version workflow for Node.js projects** using **GitHub Actions**, **feature branches**, and **snapshot versions**.

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
Merge PR feature/payment
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
feature/payment
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
git checkout -b feature/payment
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
feat: add payment service
```

---

## Step 3 — Push Feature Branch

```bash
git push origin feature/payment
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
feature/payment → main
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
feature/payment
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
feat: add payment service
chore: snapshot version 1.2.0-1
chore: snapshot version 1.2.0-2
chore: snapshot version 1.2.0-3

Merge pull request #5 from feature/payment

chore: normalize release version 1.2.0 [skip ci]
```

Tag:

```
v1.2.0
```

---

# GitHub Actions Workflows

Two pipelines exist.

## Feature Branch Workflow

Responsibilities:

- Detect feature branch
- Increment snapshot version
- Commit snapshot version

Example commit:

```
chore: snapshot version 1.2.0-2 [skip ci]
```

---

## Main Release Workflow

Responsibilities:

1. Remove snapshot suffix
2. Commit normalized version
3. Run build & tests
4. Create release tag

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
│   ├── increment-snapshot.sh
│   └── strip-snapshot-version.sh
│
├── src
│   └── index.js
│
├── test
│   └── version.test.js
│
├── package.json
└── README.md
```

---

# Scripts

## strip-snapshot-version.sh

Removes snapshot suffix.

Example:

```
1.2.0-3 → 1.2.0
```

---

## increment-snapshot.sh

Increments snapshot version.

Example:

```
1.2.0-1 → 1.2.0-2
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

This approach provides:

- Automated semantic versioning
- Consistent Git tags
- No manual version mistakes
- Clean release history
- Clear traceability from feature → release

---

# Future Improvements

Possible enhancements:

- Automatic CHANGELOG generation
- GitHub Releases creation
- npm package publishing
- automated minor/patch bump detection
- release notes generation

---

# License

MIT License
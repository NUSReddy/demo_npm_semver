# Dummy NPM Repo with Semantic Versioning and Snapshot Builds

## Purpose

This repository demonstrates a controlled semantic versioning model for npm projects using GitHub Actions.

## Versioning Model

- `main` always contains a clean release version only.
- Feature branches must manually set the intended next release version in `package.json`.
- After each successful build on a feature branch, CI appends a numeric snapshot suffix.
- Only `main` receives Git tags.

## Examples

### Current main version
`1.2.1`

### Patch release branch
Developer updates `package.json` to:
`1.2.2`

Builds on feature branch become:
- `1.2.2-1`
- `1.2.2-2`
- `1.2.2-3`

After merge to `main`:
- final version = `1.2.2`
- Git tag = `v1.2.2`

### Minor release branch
Developer updates `package.json` to:
`1.3.0`

Builds become:
- `1.3.0-1`
- `1.3.0-2`

After merge:
- final version = `1.3.0`
- Git tag = `v1.3.0`

## Important Rules

1. Do not commit directly to `main`.
2. Always create a feature branch from `main`.
3. Before first push, update `package.json` to the intended next clean release version.
4. The version must be greater than the current `main` version.
5. CI will fail if another active feature branch already reserves the same clean version.
6. Snapshot versions are created automatically only after successful builds.
7. Only clean versions on `main` are tagged.

## Developer Workflow

### Step 1: Create feature branch
```bash
git checkout main
git pull origin main
git checkout -b feature/my-change
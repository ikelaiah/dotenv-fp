# PR: Prepare dotenv-fp v1.2.1 example and documentation release

## Suggested title

`chore(release): prepare dotenv-fp v1.2.1`

## Summary

- Make `examples/` the source of truth for runnable examples
- Give beginners one documented path starting with `hello-dotenv`
- Align all five example projects with current strict-loading, validation,
  namespacing, and secret-redaction guidance
- Add PowerShell and POSIX shell scripts that build every example into the
  ignored `examples-bin/` directory
- Smoke-test all five examples on Windows and Linux CI
- Finalize v1.2.1 package metadata, changelog, documentation, and release notes

## Why this change is needed

`docs/examples.md` previously duplicated complete programs separately from the
projects in `examples/`. Those copies could drift, leaving beginners unsure
which version to follow and whether the documented code compiled.

The example projects also lacked one reproducible cross-platform build command.
Some older examples used generic environment names, printed values that could
contain credentials, or kept runtime `.env` files under version control.

## What changed

### 📚 Documentation and beginner experience

- `examples/README.md` defines the canonical learning path
- `docs/examples.md` is now a catalog linking to code compiled by CI
- Every example has a focused README with build and runtime instructions
- The main README and getting-started guide use the new build scripts

### 🔨 Builds and CI

- `build-examples.ps1` builds all canonical examples on Windows
- `build-examples.sh` builds them on Linux and macOS
- Both scripts isolate executables and compiler units under `examples-bin/`
- Windows and Linux CI build and smoke-test all five projects, including the
  default-input interactive setup flow

### 🛡️ Example safety

- Example keys are namespaced where process-environment collisions are likely
- Diagnostics report secret presence or use redaction instead of printing
  configured values
- The environment-aware example creates and cleans a unique temporary fixture
- Committed runtime `.env` files were replaced with safe `.env.example`
  templates

### 🌿 Release preparation

- Version metadata is updated to v1.2.1
- Release date is July 21, 2026
- `CHANGELOG.md` and v1.2.1 release notes document the patch
- No public API or library runtime behavior changes are included

## Local validation

- [x] FPC 3.2.2: 121 tests, 0 errors, 0 failures
- [x] Lazarus package v1.2.1 build
- [x] PowerShell script builds all five example projects
- [x] POSIX shell script syntax check
- [x] Newcomer smoke test with hostile `PORT` and `DEBUG` process variables
- [x] Runtime smoke tests for all five examples
- [x] Markdown local-link and code-fence checks
- [x] `git diff --check`

## PR validation

- [ ] GitHub Actions passes on Windows
- [ ] GitHub Actions passes on Linux

## Release follow-up

- [ ] Merge this PR
- [ ] Tag the merge commit as `v1.2.1`
- [ ] Create the GitHub release dated July 21, 2026
- [ ] Use [`RELEASE_NOTES_v1.2.1.md`](RELEASE_NOTES_v1.2.1.md) as the release
  description

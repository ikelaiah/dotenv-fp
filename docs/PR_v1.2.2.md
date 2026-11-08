# PR: Prepare dotenv-fp v1.2.2 bug-fix release

## Suggested title

`fix(release):prepare dotenv-fp v1.2.2`

## Summary

- Resolve same-file interpolation when `Prefix` is set
- Round-trip `$` through `Save()`/`Load()` with interpolation disabled
- Parse `.` decimal floats on every locale
- Stop `GetArray()` crashing on an empty separator
- Preserve file permissions on Unix in `Save()`
- Share one parser between `Load()` and `LoadFromString()`; drop dead `ParseLine()`
- Bump version metadata, changelog, docs, and release notes to v1.2.2

## Local validation

- [x] FPC 3.2.2 (Windows): 126 tests, 0 errors, 0 failures, no leaks
- [x] New tests fail against v1.2.1
- [x] Lazarus package build
- [x] `build-examples.ps1` builds all five examples

## PR validation

- [ ] GitHub Actions passes on Windows
- [ ] GitHub Actions passes on Linux (runs the Unix permission test)

## Release follow-up

- [ ] Merge this PR
- [ ] Tag the merge commit as `v1.2.2`
- [ ] Create the GitHub release using
  [`RELEASE_NOTES_v1.2.2.md`](RELEASE_NOTES_v1.2.2.md)

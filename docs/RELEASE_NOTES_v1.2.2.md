# Release Notes - 🔧 dotenv-fp v1.2.2

**Release Date:** November 8, 2026

## 🚀 Overview

Bug-fix release. No API changes; no migration needed.

## 🐛 Fixes

- **Prefix + interpolation** — with `Options.Prefix := 'APP_'`,
  `URL=${HOST}:5432` now resolves `HOST` from the same file. Previously it
  fell through to the OS environment and usually produced `:5432`.
- **Save/Load round trip** — values containing `$` saved by `Save()` load
  unchanged when `Options.Interpolate` is `False` (previously kept a `\`).
- **Locale-safe floats** — `GetFloat`, `GetFloatRequired` and `dvkFloat`
  schema checks accept `0.07` on comma-decimal locales. Locale input such as
  `0,07` still works.
- **`GetArray` empty separator** — returns the whole value instead of
  crashing.
- **Unix file permissions** — `Save()` keeps the mode of the file it replaces,
  so a `0600` `.env` stays `0600`.

## 🧹 Internal

- `Load()` and `LoadFromString()` share one parser.
- Removed the unused private `ParseLine()` method.

## ⚠️ Behaviour notes

- With a prefix, a same-file reference now wins over an OS variable of the
  unprefixed name. This matches the documented resolution order.
- `\$` in unquoted or double-quoted values now reads as `$` when
  interpolation is disabled.

## ✅ Validation

- FPC 3.2.2: 126 tests, 0 errors, 0 failures, 0 leaked blocks (heaptrc)
- New regression tests fail on v1.2.1 and pass on v1.2.2
- Lazarus package v1.2.2 build: pass
- All five examples build: pass
- Unix permission test runs on Linux CI only

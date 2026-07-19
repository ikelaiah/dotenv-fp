# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2026-07-20

### Added

- `LoadRequired()` for strict loading with absolute file paths, line numbers,
  offending keys or entries, and actionable failure reasons
- Aggregate typed validation with `TDotEnvSchemaItem`, `ValidateSchema()`, and
  `ValidateSchemaRequired()`
- `ToRedactedString()` for safer diagnostic output
- Five-minute `hello-dotenv` example and root `.env.example`
- Windows and Linux CI for tests, examples, and the Lazarus package

### Changed

- `Save()` now quotes and escapes every value and atomically replaces its
  destination through a same-directory temporary file
- `GetBoolRequired()` now rejects values that are not recognized booleans
- Single-quoted values are treated as literals and do not interpolate
- Verbose loading redacts likely secret values
- Documentation now distinguishes in-memory values from OS environment values

### Fixed

- Values containing spaces, `#`, quotes, backslashes, control characters, or
  interpolation-like text now survive a save/load round trip
- Multiline double-quoted values no longer truncate at escaped quotes
- Newcomer example keys are namespaced to avoid common OS environment collisions
- Test commands, test counts, package version metadata, API reference coverage,
  and `.env` ignore guidance

## [1.1.0] - 2025-12-16

### Added

- **Environment-aware loading**: `LoadForEnvironment()` method that automatically loads `.env` then `.env.{environment}` files
  - Auto-detects environment from `APP_ENV` or `NODE_ENV` system variables
  - Example: `Env.LoadForEnvironment('production')` loads `.env` + `.env.production`
- **Save to file**: `Save()` method to write all loaded variables to a `.env` file
  - Useful for generating configuration files programmatically
  - Example: `Env.Save('.env')`
- **Generate example files**: `GenerateExample()` method to create `.env.example` files for version control
  - Preserves keys, comments, and structure but removes values
  - Example: `Env.GenerateExample('.env', '.env.example')`
- **Interactive prompts**: `GetOrPrompt()` method for first-run setup and interactive configuration
  - Prompts user if value is missing, returns existing value if present
  - Example: `DbUrl := Env.GetOrPrompt('DATABASE_URL', 'Enter database URL', 'postgres://localhost/mydb')`

## [1.0.0] - 2025-12-11

### Added

- Initial release of dotenv-fp
- Load environment variables from `.env` files
- Variable interpolation with `${VAR}` and `$VAR` syntax
- Multi-line value support
- Quoted values (single, double, and unquoted)
- Comment support with `#` (line and inline)
- Shell-compatible `export` prefix support
- Type-safe getters: `GetInt()`, `GetBool()`, `GetFloat()`, `GetArray()`
- Default value fallbacks when keys are missing
- Validation for required variables
- Multiple file loading (`.env`, `.env.local`, `.env.production`, etc.)
- Key prefixing support (e.g., `APP_` prefix)
- Zero memory leaks using advanced records
- Cross-platform support (Windows, Linux)
- Comprehensive test suite
- Documentation and examples

[Unreleased]: https://github.com/ikelaiah/dotenv-fp/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/ikelaiah/dotenv-fp/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/ikelaiah/dotenv-fp/releases/tag/v1.1.0
[1.0.0]: https://github.com/ikelaiah/dotenv-fp/releases/tag/v1.0.0

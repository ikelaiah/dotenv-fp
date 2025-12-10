# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.0.0]: https://github.com/ikelaiah/dotenv-fp/releases/tag/v1.0.0

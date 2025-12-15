# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.0.0]: https://github.com/ikelaiah/dotenv-fp/releases/tag/v1.0.0

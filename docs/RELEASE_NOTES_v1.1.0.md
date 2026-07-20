# Release Notes - dotenv-fp v1.1.0

**Release Date:** December 16, 2025

## Overview

Version 1.1.0 adds four practical, easy-to-use features that enhance the dotenv-fp library with minimal cognitive burden for both new and experienced developers. All features follow industry-standard patterns familiar to developers from other ecosystems.

## New Features

### 1. 🌍 Environment-Aware Loading

**Method:** `LoadForEnvironment(const AEnvironment: string = ''): Boolean`

Automatically loads base configuration from `.env`, then environment-specific overrides from `.env.{environment}`.

**Key Benefits:**
- Industry-standard pattern (used in Node.js, Rails, Django, etc.)
- Auto-detects environment from `APP_ENV` or `NODE_ENV` system variables
- Zero cognitive burden - developers already know this pattern
- Simplifies managing dev/staging/production configs

**Usage:**
```pascal
// Load for specific environment
Env.LoadForEnvironment('production');  // Loads .env + .env.production

// Auto-detect from system environment
Env.LoadForEnvironment();  // Uses APP_ENV or NODE_ENV
```

**Implementation:** ~45 lines of code

---

### 2. 💾 Save to File

**Method:** `Save(const APath: string = '.env'): Boolean`

Saves all loaded environment variables to a `.env` file.

**Key Benefits:**
- Generate `.env` files programmatically
- Persist runtime configuration changes
- Useful for installers and setup scripts
- Simple API - just one method call

**Usage:**
```pascal
Env := TDotEnv.Create;
Env.SetToEnv('DATABASE_URL', 'postgres://localhost/mydb');
Env.SetToEnv('PORT', '3000');
Env.Save('.env');  // Write to disk
```

**Implementation:** ~35 lines of code

---

### 3. 💬 Interactive Prompts

**Method:** `GetOrPrompt(const AKey, APrompt: string; const ADefault: string = ''): string`

Gets a value by key, or prompts the user if the value is missing.

**Key Benefits:**
- Perfect for first-run setup scripts
- Interactive configuration wizards
- No need for separate input handling code
- Stored value can be saved with `Save()`

**Usage:**
```pascal
DbUrl := Env.GetOrPrompt('DATABASE_URL',
                        'Enter database URL',
                        'postgres://localhost/mydb');
// If DATABASE_URL exists, returns it
// If missing, prompts user and stores the answer
```

**Implementation:** ~25 lines of code

---

### 4. 📋 Generate Example Files

**Method:** `GenerateExample(const ASourcePath: string = '.env'; const ADestPath: string = '.env.example'): Boolean`

Creates a `.env.example` file from a source `.env` file, preserving keys and comments but removing values.

**Key Benefits:**
- Standard Git best practice - commit `.env.example`, not `.env`
- Documents required configuration for team members
- Preserves file structure and comments
- One command to generate template

**Usage:**
```pascal
Env.GenerateExample('.env', '.env.example');
```

**Input (.env):**
```bash
# Database config
DATABASE_URL=postgres://localhost/mydb
PORT=3000
```

**Output (.env.example):**
```bash
# Database config
DATABASE_URL=
PORT=
```

**Implementation:** ~75 lines of code

---

## Examples

Two new comprehensive examples added as Lazarus projects:

1. **examples/interactive-setup/** - Interactive setup wizard using `GetOrPrompt()` and `Save()`
   - Includes `.lpi` project file and comprehensive README

2. **examples/environment-aware/** - Multi-environment loading with `LoadForEnvironment()`
   - Includes `.lpi` project file and comprehensive README

### ⚠️ Important Security Note for Examples

The example programs create files with **NO actual secrets** - only demonstration values like `DEBUG=true` or `PORT=3000`. They are meant to show the loading pattern, not production security practices.

**Real-world security best practices:**

1. **NEVER commit files with actual secrets to Git**, even if named `.env.production`
2. Use `.env.example` files (empty values) for version control
3. Add `.env*` to `.gitignore` (except `.env.example`)
4. Store real secrets in:
   - Environment variables (set by hosting platform: Heroku, AWS, Azure, etc.)
   - Secret management tools (AWS Secrets Manager, HashiCorp Vault, etc.)
   - Local `.env` files (NOT committed to Git)

## Testing

- ✅ All 96 existing tests pass
- ✅ Compiles cleanly with FPC 3.2.2+
- ✅ No breaking changes to existing API
- ✅ Zero new dependencies

## Documentation Updates

- ✅ README.md updated with new features
- ✅ CHANGELOG.md updated
- ✅ Version number bumped to 1.1.0
- ✅ Code comments added for all new methods
- ✅ Example programs created

## Migration Guide

**From v1.0.0 to v1.1.0:** No breaking changes! All existing code continues to work.

Simply update your library file and start using the new features:

```pascal
// Old way still works
Env := TDotEnv.Create;
Env.Load('.env');

// New way - more convenient
Env := TDotEnv.Create;
Env.LoadForEnvironment('production');
```

## Future Compatibility

All new features are designed to be:
- ✅ Simple and intuitive
- ✅ Following established patterns
- ✅ Easy to understand
- ✅ Well-documented
- ✅ Tested and reliable

## Developer Experience

**Total code added:** ~180 lines of implementation + ~100 lines of documentation

**Cognitive load:** Minimal - all features use familiar patterns from other ecosystems

**Learning curve:** Near zero for developers familiar with Node.js, Python, Ruby, or similar environments

## What's Next?

Version 1.1.0 focuses on practical, commonly-needed features. Future versions may include:
- Schema validation with type checking
- File watching and auto-reload
- Encryption support for sensitive values
- Export to other formats (JSON, XML, INI)

---

**Thank you for using dotenv-fp!** 🎉

For issues or suggestions, please visit: https://github.com/ikelaiah/dotenv-fp

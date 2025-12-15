# Environment-Aware Loading Example

**Demonstrates:** `LoadForEnvironment()` method from dotenv-fp v1.1.0

## Overview

This example shows how to use the `LoadForEnvironment()` method to automatically load environment-specific configuration files. This is a common pattern in modern web development frameworks like Node.js, Rails, and Django.

## ⚠️ Security Note

**This example creates files with NO actual secrets** - only demonstration values like `DEBUG=true` or `PORT=3000`.

In real-world applications, **NEVER commit files containing actual secrets** (API keys, passwords, database credentials) to Git, even if they're named `.env.production` or `.env.development`.

## Pattern

This example demonstrates the file loading pattern:

```
.env                 # Base configuration
.env.development     # Development overrides
.env.production      # Production overrides
```

## What This Example Does

1. Creates test `.env` files for different environments (NO secrets, just demo values)
2. Demonstrates loading for specific environments (development, production)
3. Shows auto-detection from `APP_ENV` or `NODE_ENV` system variables
4. Displays which files were loaded and their values

## Running the Example

### In Lazarus IDE:
1. Open `environment_example.lpi` in Lazarus
2. Press F9 to compile and run

### From Command Line:
```bash
# Using Lazarus compiler
lazbuild environment_example.lpi
./environment_example

# Or using FPC directly
fpc -Mdelphi environment_example.pas
./environment_example
```

## Testing with Environment Variables

Try setting environment variables to see auto-detection:

### Windows:
```cmd
SET APP_ENV=development
environment_example.exe
```

### Linux/Mac:
```bash
export APP_ENV=development
./environment_example
```

## Features Demonstrated

- `LoadForEnvironment('production')` - Load for specific environment
- `LoadForEnvironment()` - Auto-detect from APP_ENV/NODE_ENV
- `LoadedFiles` property - Track which files were loaded
- Environment variable cascading and overrides

## Expected Output

The program will:
1. Create test `.env` files
2. Load and display configuration for development environment
3. Load and display configuration for production environment
4. Show auto-detection behavior
5. List all loaded files

## Best Practices for Real Applications

### Two Common Patterns:

#### Pattern 1: Template Files (Most Secure)
```gitignore
# Commit these (templates with empty values):
.env.example
.env.development.example
.env.production.example

# Do NOT commit (contain actual secrets):
.env
.env.development
.env.production
.env.local
```

#### Pattern 2: Non-Secret Config Only
```gitignore
# OK to commit if they contain ONLY non-sensitive settings:
.env.development      # e.g., DEBUG=true, LOG_LEVEL=verbose
.env.production       # e.g., DEBUG=false, LOG_LEVEL=error

# NEVER commit (actual secrets):
.env                  # Contains actual credentials
.env.local            # Local overrides with secrets
```

### The Golden Rule

**NEVER commit files with actual secrets to Git**, regardless of filename. Use:
- Environment variables set by your hosting platform (Heroku, AWS, Azure, etc.)
- Secret management tools (AWS Secrets Manager, HashiCorp Vault, etc.)
- `.env.example` template files showing structure but not values

### Recommended .gitignore

```gitignore
# Ignore all .env files
.env
.env.local
.env.*.local

# Only commit .example files
!.env*.example
```

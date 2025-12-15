# Environment-Aware Loading Example

**Demonstrates:** `LoadForEnvironment()` method from dotenv-fp v1.1.0

## Overview

This example shows how to use the `LoadForEnvironment()` method to automatically load environment-specific configuration files. This is a common pattern in modern web development frameworks like Node.js, Rails, and Django.

## Pattern

```
.env                 # Base configuration (committed to Git)
.env.development     # Development overrides (committed to Git)
.env.production      # Production overrides (committed to Git)
.env.local          # Local overrides (NOT committed, in .gitignore)
```

## What This Example Does

1. Creates test `.env` files for different environments
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

## Best Practices

1. **Commit to Git:**
   - `.env.example` (template)
   - `.env.development`
   - `.env.production`

2. **Do NOT commit:**
   - `.env` (local configuration)
   - `.env.local` (local overrides)

3. **Add to .gitignore:**
   ```gitignore
   .env
   .env.local
   ```

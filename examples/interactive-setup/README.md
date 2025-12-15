# Interactive Setup Example

**Demonstrates:** `GetOrPrompt()`, `Save()`, and `GenerateExample()` methods from dotenv-fp v1.1.0

## Overview

This example shows how to create an interactive configuration script that prompts users for missing values, saves the configuration, and generates an example file for version control.

## What This Example Does

1. Checks for existing `.env` file and loads it if present
2. Prompts user for configuration values (or uses existing values)
3. Saves all configuration to `.env`
4. Generates `.env.example` template file

## Use Cases

Perfect for:
- First-run application setup
- Installation wizards
- Configuration management tools
- Onboarding new developers

## Running the Example

### In Lazarus IDE:
1. Open `setup_example.lpi` in Lazarus
2. Press F9 to compile and run

### From Command Line:
```bash
# Using Lazarus compiler
lazbuild setup_example.lpi
./setup_example

# Or using FPC directly
fpc -Mdelphi setup_example.pas
./setup_example
```

## Interactive Flow

When you run the program:

```
===========================================
  dotenv-fp v1.1.0 - Setup Example
===========================================

Checking for existing .env file...
No .env file found. Starting fresh setup.

=== Application Configuration ===

Enter application name [MyPascalApp]: █
```

The program will prompt for:
- Application name
- Database URL
- Port number
- Debug mode setting

If values already exist in `.env`, they are shown as defaults.

## Features Demonstrated

- `Load()` - Load existing configuration
- `GetOrPrompt()` - Interactive prompts with defaults
- `Save()` - Save configuration to `.env`
- `GenerateExample()` - Create `.env.example` template

## Files Created

After running, you'll have:

- `.env` - Your actual configuration (DO NOT commit to Git)
- `.env.example` - Template file (commit this to Git)

## Example Output

```
===========================================
  Configuration Summary
===========================================
APP_NAME     : MyPascalApp
DATABASE_URL : postgres://localhost/mydb
PORT         : 3000
DEBUG        : false

Saving configuration to .env...
✓ Configuration saved successfully!
Generating .env.example...
✓ Example file created successfully!

===========================================
Setup complete!

Files created:
  - .env          (your configuration - DO NOT commit!)
  - .env.example  (template - commit to Git)
===========================================
```

## .env.example Pattern

The generated `.env.example` preserves structure but removes values:

**Input (.env):**
```
APP_NAME=MyPascalApp
DATABASE_URL=postgres://localhost/mydb
PORT=3000
```

**Output (.env.example):**
```
APP_NAME=
DATABASE_URL=
PORT=
```

This allows team members to see what configuration is needed without exposing actual values.

## Best Practices

1. **Always commit** `.env.example` to version control
2. **Never commit** `.env` (add to .gitignore)
3. Use meaningful prompts that explain what each value is for
4. Provide sensible defaults where possible
5. Run setup script on first deployment to each environment

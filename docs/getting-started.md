# 🚀 Getting Started

This guide will help you set up dotenv-fp in your Free Pascal project.

## Prerequisites

- **Free Pascal 3.2.2** or later
- **Lazarus 4.0+** (optional, for IDE support)

## Installation

### Option 1: Copy the Unit (Simplest)

1. Copy `src/DotEnv.pas` to your project folder
2. Add `DotEnv` to your `uses` clause

```pascal
uses
  DotEnv;
```

### Option 2: Add to Unit Search Path

1. Clone or download the repository
2. In Lazarus: **Project → Project Options → Compiler Options → Paths**
3. Add the `src` folder to **Other unit files**

### Option 3: Command Line

```bash
fpc -Fu/path/to/dotenv-fp/src myprogram.pas
```

## Your First `.env` File

Create a `.env` file in your project root:

```bash
# Database configuration
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=myapp

# Application settings
DEBUG=true
LOG_LEVEL=info
```

## Basic Usage

```pascal
program HelloDotEnv;

{$mode objfpc}{$H+}{$J-}

uses
  DotEnv;

var
  Env: TDotEnv;
begin
  // Create and load
  Env := TDotEnv.Create;
  Env.Load;  // Loads .env from current directory
  
  // Read values
  WriteLn('Host: ', Env.Get('DATABASE_HOST'));
  WriteLn('Port: ', Env.GetInt('DATABASE_PORT', 5432));
  WriteLn('Debug: ', Env.GetBool('DEBUG', False));
  
  // No need to free! Advanced records handle cleanup automatically.
end.
```

## Loading Different Files

```pascal
// Load specific file
Env.Load('.env.production');

// Load multiple files (later files override earlier ones)
Env.LoadMultiple(['.env', '.env.local']);

// Load from string (great for testing)
Env.LoadFromString('KEY=value');
```

## Using Default Values

Always provide defaults for optional configuration:

```pascal
// String with default
Host := Env.Get('HOST', 'localhost');

// Integer with default
Port := Env.GetInt('PORT', 3000);

// Boolean with default
Debug := Env.GetBool('DEBUG', False);

// Float with default
Rate := Env.GetFloat('RATE', 0.5);
```

## Required Values

For configuration that must exist:

```pascal
// Raises EDotEnvMissingKey if not found
SecretKey := Env.GetRequired('SECRET_KEY');
Port := Env.GetIntRequired('PORT');
```

## Global Helper Functions

For simple scripts:

```pascal
uses DotEnv;

begin
  DotEnvLoad;  // Load .env
  
  WriteLn(DotEnvGet('DATABASE_URL'));
  WriteLn(DotEnvGet('PORT', '3000'));
end.
```

## Next Steps

- Learn about [Configuration Options](configuration.md)
- Understand the [.env Syntax](syntax.md)
- See the complete [API Reference](api-reference.md)
- Check out [Examples](examples.md) for real-world patterns

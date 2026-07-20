# 🚀 Getting Started

This guide will help you set up dotenv-fp in your Free Pascal project.

## Prerequisites

- **Free Pascal 3.2.2** or later
- **Lazarus 4.0+** (optional, for IDE support)

## Installation

To try the included newcomer example from a repository checkout:

```bash
cp .env.example .env
fpc -B "-Fusrc" "-FUexamples/hello-dotenv" examples/hello-dotenv/hello_dotenv.pas
./examples/hello-dotenv/hello_dotenv
```

In Windows PowerShell, use `Copy-Item .env.example .env`, then run
`examples\hello-dotenv\hello_dotenv.exe`. Lazarus users can build the same
example with:

```bash
lazbuild --build-mode=Release examples/hello-dotenv/hello_dotenv.lpi
```

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
fpc "-Fu/path/to/dotenv-fp/src" myprogram.pas
```

## Your First `.env` File

Create a `.env` file in your project root:

```bash
# Database configuration
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=myapp

# Application settings
APP_DEBUG=true
APP_LOG_LEVEL=info
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
  Env := TDotEnv.Create;
  try
    Env.LoadRequired;  // Actionable error if .env is missing or malformed

    WriteLn('Host: ', Env.Get('DATABASE_HOST'));
    WriteLn('Port: ', Env.GetInt('DATABASE_PORT', 5432));
    WriteLn('Debug: ', Env.GetBool('APP_DEBUG', False));
  except
    on E: EDotEnvException do
    begin
      WriteLn(StdErr, 'Configuration error: ', E.Message);
      Halt(1);
    end;
  end;

  // No need to free: advanced records handle cleanup automatically.
end.
```

## Loading Different Files

```pascal
// Require one specific file
Env.LoadRequired('.env.production');

// Load .env followed by .env.production
Env.LoadForEnvironment('production');

// Read APP_ENV, then NODE_ENV; load .env plus the detected file
Env.LoadForEnvironment;

// Custom permissive layering (later files override earlier ones)
Env.LoadMultiple(['.env', '.env.local']);

// Load from string (great for testing)
Env.LoadFromString('KEY=value');
```

`LoadForEnvironment()` and `LoadMultiple()` retain permissive loading semantics.
Use `LoadRequired()` when a particular file must exist and be syntactically
valid.

## Using Default Values

Provide explicit defaults for optional configuration:

```pascal
// String with default
Host := Env.Get('APP_HOST', 'localhost');

// Integer with default
Port := Env.GetInt('APP_PORT', 3000);

// Boolean with default
Debug := Env.GetBool('APP_DEBUG', False);

// Float with default
Rate := Env.GetFloat('APP_RATE', 0.5);
```

## Required Values

For configuration that must exist, validate all keys and types together:

```pascal
Env.ValidateSchemaRequired([
  TDotEnvSchemaItem.Create('DATABASE_HOST'),
  TDotEnvSchemaItem.Create('DATABASE_PORT', dvkInteger),
  TDotEnvSchemaItem.Create('APP_DEBUG', dvkBoolean)
]);
```

## Global Helper Functions

For simple scripts where a missing `.env` file is acceptable:

```pascal
uses DotEnv;

begin
  DotEnvLoad;  // Load .env
  
  WriteLn(DotEnvGet('APP_NAME', 'Application'));
  WriteLn(DotEnvGet('APP_PORT', '3000'));
end.
```

## Next Steps

- Learn about [Configuration Options](configuration.md)
- Understand the [.env Syntax](syntax.md)
- See the complete [API Reference](api-reference.md)
- Check out [Examples](examples.md) for real-world patterns

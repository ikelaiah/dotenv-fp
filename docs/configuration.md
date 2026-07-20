# ⚙️ Configuration Options

dotenv-fp provides several options to customize how `.env` files are loaded and processed.

## TDotEnvOptions

All options are configured through the `TDotEnvOptions` record:

```pascal
var
  Options: TDotEnvOptions;
begin
  Options := TDotEnvOptions.Default;  // Start with defaults
  // ... customize options ...
  
  Env := TDotEnv.CreateWithOptions(Options);
  Env.Load;
end;
```

## Available Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Override` | `Boolean` | `False` | Let loaded values shadow matching OS keys inside this instance |
| `Interpolate` | `Boolean` | `True` | Enable `${VAR}` variable interpolation |
| `Verbose` | `Boolean` | `False` | Print debug information with likely secrets redacted |
| `Prefix` | `String` | `''` | Add prefix to all loaded key names |
| `Encoding` | `String` | `'UTF-8'` | Reserved and currently ignored; use UTF-8 files |

## Override

**Default:** `False`

When `False`, a key already present in the operating-system environment wins.
When `True`, a value loaded from a dotenv file can shadow that key inside the
current `TDotEnv` instance. This option never modifies the operating-system
environment itself.

```pascal
// Operating-system environment has APP_PORT=8080

Options := TDotEnvOptions.Default;
Options.Override := False;
Env := TDotEnv.CreateWithOptions(Options);
Env.Load;
WriteLn(Env.Get('APP_PORT'));  // Still '8080' from the OS

Options.Override := True;
Env := TDotEnv.CreateWithOptions(Options);
Env.Load;
WriteLn(Env.Get('APP_PORT'));  // Uses the value loaded from .env
```

**Use cases:**
- `False`: Respect deployment environment settings (production)
- `True`: Force specific values during development/testing

## Interpolate

**Default:** `True`

Enables variable interpolation using `${VAR}` or `$VAR` syntax.

```bash
# .env file
BASE_URL=https://api.example.com
API_ENDPOINT=${BASE_URL}/v1/users
```

```pascal
Options := TDotEnvOptions.Default;
Options.Interpolate := True;
Env := TDotEnv.CreateWithOptions(Options);
Env.Load;
WriteLn(Env.Get('API_ENDPOINT'));  // 'https://api.example.com/v1/users'

Options.Interpolate := False;
Env := TDotEnv.CreateWithOptions(Options);
Env.Load;
WriteLn(Env.Get('API_ENDPOINT'));  // '${BASE_URL}/v1/users' (literal)
```

**Resolution order:**
1. Variables defined earlier in the same `.env` file
2. System environment variables

Single-quoted values are always literal. In double-quoted values, use `\$` when
a dollar sign must remain literal instead of starting interpolation.

## Verbose

**Default:** `False`

When `True`, prints debug information during loading. Values for likely secret
keys are replaced by `[REDACTED]`.

```pascal
Options := TDotEnvOptions.Default;
Options.Verbose := True;
Env := TDotEnv.CreateWithOptions(Options);
Env.Load;
// Outputs:
// DotEnv: Loaded DATABASE_PASSWORD=[REDACTED]
// DotEnv: Loaded APP_PORT=3000
// ...
```

## Prefix

**Default:** `''` (empty)

Adds a prefix to all loaded variable names. Useful for namespacing.

```bash
# .env file
HOST=localhost
PORT=3000
```

```pascal
Options := TDotEnvOptions.Default;
Options.Prefix := 'APP_';
Env := TDotEnv.CreateWithOptions(Options);
Env.Load;

// Variables are now:
WriteLn(Env.Get('APP_HOST'));  // 'localhost'
WriteLn(Env.Get('APP_PORT'));  // '3000'

// Original names don't work:
WriteLn(Env.Get('HOST'));  // '' (empty)
```

**Use cases:**
- Loading multiple `.env` files without conflicts
- Organizing variables by application/service
- Multi-tenant applications

## Complete Example

```pascal
program ConfigExample;

{$mode objfpc}{$H+}{$J-}

uses
  DotEnv;

var
  Env: TDotEnv;
  Options: TDotEnvOptions;
begin
  // Configure all options
  Options := TDotEnvOptions.Default;
  Options.Override := True;       // Prefer loaded values inside this instance
  Options.Interpolate := True;    // Enable ${VAR} syntax
  Options.Verbose := True;        // Debug output with likely secrets redacted
  Options.Prefix := 'MYAPP_';     // Prefix all keys
  
  // Create with options and load
  Env := TDotEnv.CreateWithOptions(Options);
  Env.LoadRequired('.env');
  Env.Load('.env.local');  // Override with local settings
  
  // Access prefixed variables
  WriteLn('Host: ', Env.Get('MYAPP_DATABASE_HOST'));
  WriteLn('Port: ', Env.GetInt('MYAPP_PORT', 3000));
end.
```

## Environment-Specific Configuration

Use `LoadForEnvironment()` for the conventional `.env` plus
`.env.{environment}` pattern:

```pascal
Env.LoadForEnvironment('development');

// With no argument, APP_ENV is checked first, followed by NODE_ENV.
Env.LoadForEnvironment;
```

Use `LoadMultiple()` when the application needs a custom order:

```pascal
// Load base config, then environment-specific overrides
Env.LoadMultiple([
  '.env',              // Base configuration
  '.env.development',  // Environment-specific
  '.env.local'         // Machine-specific overrides (gitignored)
]);
```

Both helpers are permissive and return whether at least one file loaded. Call
`LoadRequired()` directly when a particular file is mandatory.

**Recommended `.gitignore`:**
```gitignore
.env
.env.*
!.env.example
!.env.*.example
```

This keeps local settings out of version control while allowing explicit
`.example` templates.

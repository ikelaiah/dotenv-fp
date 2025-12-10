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
| `Override` | `Boolean` | `False` | Override existing system environment variables |
| `Interpolate` | `Boolean` | `True` | Enable `${VAR}` variable interpolation |
| `Verbose` | `Boolean` | `False` | Print debug information while loading |
| `Prefix` | `String` | `''` | Add prefix to all loaded key names |
| `Encoding` | `String` | `'UTF-8'` | File encoding |

## Override

**Default:** `False`

When `False`, existing system environment variables are preserved. When `True`, values from `.env` files will override them.

```pascal
// System has PORT=8080

Options.Override := False;
Env.Load;
WriteLn(Env.Get('PORT'));  // Still '8080' from system

Options.Override := True;
Env.Load;
WriteLn(Env.Get('PORT'));  // Now uses value from .env
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
Options.Interpolate := True;
Env.Load;
WriteLn(Env.Get('API_ENDPOINT'));  // 'https://api.example.com/v1/users'

Options.Interpolate := False;
Env.Load;
WriteLn(Env.Get('API_ENDPOINT'));  // '${BASE_URL}/v1/users' (literal)
```

**Resolution order:**
1. Variables defined earlier in the same `.env` file
2. System environment variables

## Verbose

**Default:** `False`

When `True`, prints debug information during loading. Useful for troubleshooting.

```pascal
Options.Verbose := True;
Env.Load;
// Outputs:
// Loading: .env
// Parsed: DATABASE_URL = postgresql://localhost/mydb
// Parsed: PORT = 3000
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
Options.Prefix := 'APP_';
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
  Options.Override := True;       // Override system vars
  Options.Interpolate := True;    // Enable ${VAR} syntax
  Options.Verbose := True;        // Debug output
  Options.Prefix := 'MYAPP_';     // Prefix all keys
  
  // Create with options and load
  Env := TDotEnv.CreateWithOptions(Options);
  Env.Load('.env');
  Env.Load('.env.local');  // Override with local settings
  
  // Access prefixed variables
  WriteLn('Host: ', Env.Get('MYAPP_DATABASE_HOST'));
  WriteLn('Port: ', Env.GetInt('MYAPP_PORT', 3000));
end.
```

## Environment-Specific Configuration

A common pattern is to load multiple files:

```pascal
// Load base config, then environment-specific overrides
Env.LoadMultiple([
  '.env',              // Base configuration
  '.env.local',        // Local overrides (gitignored)
  '.env.development'   // Environment-specific
]);
```

**Recommended `.gitignore`:**
```
.env.local
.env.*.local
```

This keeps sensitive local settings out of version control while sharing safe defaults.

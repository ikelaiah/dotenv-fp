# 💡 Examples

Real-world examples and patterns for using dotenv-fp.

## Table of Contents

- [💡 Examples](#-examples)
  - [Table of Contents](#table-of-contents)
  - [Basic Application](#basic-application)
  - [Web Server Configuration](#web-server-configuration)
  - [Database Connection](#database-connection)
  - [Multi-Environment Setup](#multi-environment-setup)
  - [Validation Pattern](#validation-pattern)
  - [Testing with Mock Environment](#testing-with-mock-environment)
  - [Feature Flags](#feature-flags)
  - [Logging Configuration](#logging-configuration)
  - [Tips \& Best Practices](#tips--best-practices)

## Basic Application

An application whose configuration is optional can deliberately use
permissive loading and defaults:

**.env**
```bash
APP_NAME=MyApp
APP_VERSION=1.0.0
APP_DEBUG=true
```

**main.pas**
```pascal
program BasicApp;

{$mode objfpc}{$H+}{$J-}

uses
  DotEnv;

var
  Env: TDotEnv;
begin
  Env := TDotEnv.Create;
  
  if not Env.Load then
  begin
    WriteLn('Warning: .env file not found, using defaults');
  end;
  
  WriteLn('Starting ', Env.Get('APP_NAME', 'Application'));
  WriteLn('Version: ', Env.Get('APP_VERSION', '0.0.0'));
  
  if Env.GetBool('APP_DEBUG', False) then
    WriteLn('Debug mode enabled');
end.
```

## Web Server Configuration

**.env**
```bash
# Server
APP_HOST=0.0.0.0
APP_PORT=8080
APP_MAX_CONNECTIONS=100

# SSL
APP_SSL_ENABLED=true
APP_SSL_CERT_PATH=/etc/ssl/cert.pem
APP_SSL_KEY_PATH=/etc/ssl/key.pem

# CORS
APP_ALLOWED_ORIGINS=http://localhost:3000,https://myapp.com
```

**server.pas**
```pascal
program WebServer;

{$mode objfpc}{$H+}{$J-}

uses
  Types, DotEnv;

var
  Env: TDotEnv;
  Host: string;
  Port, MaxConn: Integer;
  SSLEnabled: Boolean;
  Origins: TStringDynArray;
  I: Integer;
begin
  Env := TDotEnv.Create;
  Env.LoadRequired;
  Env.ValidateSchemaRequired([
    TDotEnvSchemaItem.Create('APP_HOST'),
    TDotEnvSchemaItem.Create('APP_PORT', dvkInteger),
    TDotEnvSchemaItem.Create('APP_MAX_CONNECTIONS', dvkInteger),
    TDotEnvSchemaItem.Create('APP_SSL_ENABLED', dvkBoolean)
  ]);
  
  // Server settings
  Host := Env.GetRequired('APP_HOST');
  Port := Env.GetIntRequired('APP_PORT');
  MaxConn := Env.GetIntRequired('APP_MAX_CONNECTIONS');
  
  WriteLn('Server: ', Host, ':', Port);
  WriteLn('Max connections: ', MaxConn);
  
  // SSL configuration
  SSLEnabled := Env.GetBoolRequired('APP_SSL_ENABLED');
  if SSLEnabled then
  begin
    WriteLn('SSL Certificate: ', Env.GetRequired('APP_SSL_CERT_PATH'));
    WriteLn('SSL Key: ', Env.GetRequired('APP_SSL_KEY_PATH'));
  end;
  
  // CORS origins
  Origins := Env.GetArray('APP_ALLOWED_ORIGINS');
  WriteLn('Allowed origins:');
  for I := 0 to High(Origins) do
    WriteLn('  - ', Origins[I]);
end.
```

## Database Connection

**.env**
```bash
# Database
DB_DRIVER=postgresql
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp_development
DB_USER=postgres
DB_PASSWORD=local-development-only
DB_POOL_SIZE=10
DB_TIMEOUT=30

# Constructed URL (uses interpolation)
DATABASE_URL=${DB_DRIVER}://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}
```

**database.pas**
```pascal
program DatabaseExample;

{$mode objfpc}{$H+}{$J-}

uses
  DotEnv;

var
  Env: TDotEnv;
begin
  Env := TDotEnv.Create;
  Env.LoadRequired;
  Env.ValidateSchemaRequired([
    TDotEnvSchemaItem.Create('DB_HOST'),
    TDotEnvSchemaItem.Create('DB_PORT', dvkInteger),
    TDotEnvSchemaItem.Create('DB_NAME'),
    TDotEnvSchemaItem.Create('DB_USER'),
    TDotEnvSchemaItem.Create('DB_PASSWORD'),
    TDotEnvSchemaItem.Create('DB_POOL_SIZE', dvkInteger),
    TDotEnvSchemaItem.Create('DB_TIMEOUT', dvkInteger),
    TDotEnvSchemaItem.Create('DATABASE_URL')
  ]);

  // Pass DATABASE_URL directly to the database driver; do not log it because
  // it contains credentials.
  WriteLn('Database configuration validated.');
  WriteLn('Host: ', Env.Get('DB_HOST'));
  WriteLn('Port: ', Env.GetIntRequired('DB_PORT'));
  WriteLn('Database: ', Env.Get('DB_NAME'));
  WriteLn('Pool size: ', Env.GetIntRequired('DB_POOL_SIZE'));
  WriteLn('Timeout: ', Env.GetIntRequired('DB_TIMEOUT'), 's');
end.
```

## Multi-Environment Setup

**Project structure:**
```
project/
├── .env.example         # Safe template (committed)
├── .env                 # Local base configuration (gitignored)
├── .env.local           # Local overrides (gitignored)
├── .env.development     # Development settings (gitignored)
├── .env.production      # Production settings (gitignored)
└── .env.test            # Test settings (gitignored)
```

**.env**
```bash
APP_NAME=MyApp
APP_LOG_LEVEL=info
```

**.env.development**
```bash
APP_DEBUG=true
APP_LOG_LEVEL=debug
DATABASE_URL=postgresql://localhost/myapp_dev
```

**.env.production**
```bash
APP_DEBUG=false
APP_LOG_LEVEL=warn
# DATABASE_URL set via system environment
```

**app.pas**
```pascal
program MultiEnvApp;

{$mode objfpc}{$H+}{$J-}

uses
  DotEnv;

var
  Env: TDotEnv;
  Environment: string;
begin
  Env := TDotEnv.Create;

  // APP_ENV takes precedence over NODE_ENV; development is the local default.
  Environment := Env.GetFromEnv('APP_ENV',
    Env.GetFromEnv('NODE_ENV', 'development'));
  if not Env.LoadForEnvironment(Environment) then
  begin
    WriteLn(StdErr, 'No dotenv configuration file was found.');
    Halt(1);
  end;

  // Optional machine-specific overrides are loaded last.
  Env.Load('.env.local');

  WriteLn('Environment: ', Environment);
  WriteLn('Debug: ', Env.GetBool('APP_DEBUG', False));
  WriteLn('Log level: ', Env.Get('APP_LOG_LEVEL', 'info'));
end.
```

Keep real credentials in ignored local files, deployment environment
variables, or a secret manager. Commit only `.env.example` templates.

## Validation Pattern

Report every missing or incorrectly typed setting in one startup pass:

```pascal
program ValidatedApp;

{$mode objfpc}{$H+}{$J-}

uses
  Types, DotEnv;

var
  Env: TDotEnv;
  Errors: TStringDynArray;
  I: Integer;
begin
  Env := TDotEnv.Create;
  Env.LoadRequired;

  if not Env.ValidateSchema([
    TDotEnvSchemaItem.Create('DATABASE_URL'),
    TDotEnvSchemaItem.Create('APP_SECRET_KEY'),
    TDotEnvSchemaItem.Create('APP_PORT', dvkInteger),
    TDotEnvSchemaItem.Create('APP_DEBUG', dvkBoolean)
  ], Errors) then
  begin
    WriteLn('ERROR: Invalid environment configuration:');
    WriteLn;

    for I := 0 to High(Errors) do
      WriteLn('  - ', Errors[I]);

    WriteLn;
    WriteLn('Please check your .env file.');
    Halt(1);
  end;

  WriteLn('Configuration validated successfully!');
end.
```

## Testing with Mock Environment

Load configuration from strings for testing:

```pascal
program TestExample;

{$mode objfpc}{$H+}{$J-}

uses
  DotEnv;

procedure TestWithMockEnv;
var
  Env: TDotEnv;
  MockConfig: string;
begin
  MockConfig := 
    'APP_DATABASE_URL=postgresql://test/testdb' + LineEnding +
    'APP_DEBUG=true' + LineEnding +
    'APP_API_KEY=test-key-123';
  
  Env := TDotEnv.Create;
  Env.LoadFromString(MockConfig);
  
  // Run assertions
  Assert(Env.Get('APP_DATABASE_URL') = 'postgresql://test/testdb');
  Assert(Env.GetBool('APP_DEBUG') = True);
  Assert(Env.Get('APP_API_KEY') = 'test-key-123');
  
  WriteLn('All tests passed!');
end;

begin
  TestWithMockEnv;
end.
```

## Feature Flags

**.env**
```bash
# Feature flags
APP_FEATURE_NEW_UI=true
APP_FEATURE_DARK_MODE=false
APP_FEATURE_BETA_API=true
APP_FEATURE_ANALYTICS=true

# A/B testing
APP_AB_TEST_CHECKOUT=variant_b
APP_AB_TEST_SIGNUP=control
```

```pascal
program FeatureFlags;

{$mode objfpc}{$H+}{$J-}

uses
  DotEnv;

var
  Env: TDotEnv;
  Variant: string;
begin
  Env := TDotEnv.Create;
  Env.LoadRequired;
  
  // Check features
  if Env.GetBool('APP_FEATURE_NEW_UI', False) then
    WriteLn('Using new UI')
  else
    WriteLn('Using classic UI');
  
  if Env.GetBool('APP_FEATURE_DARK_MODE', False) then
    WriteLn('Dark mode enabled');
  
  if Env.GetBool('APP_FEATURE_BETA_API', False) then
    WriteLn('Beta API enabled');
  
  // A/B test variant
  Variant := Env.Get('APP_AB_TEST_CHECKOUT', 'control');
  if Variant = 'variant_a' then
    WriteLn('Checkout: Variant A')
  else if Variant = 'variant_b' then
    WriteLn('Checkout: Variant B')
  else
    WriteLn('Checkout: Control group');
end.
```

## Logging Configuration

**.env**
```bash
# Logging
APP_LOG_LEVEL=debug
APP_LOG_FORMAT=json
APP_LOG_OUTPUT=file
APP_LOG_FILE=/var/log/myapp.log
APP_LOG_MAX_SIZE=10485760
APP_LOG_ROTATE=true
APP_LOG_KEEP_FILES=5
```

```pascal
program LoggingConfig;

{$mode objfpc}{$H+}{$J-}

uses
  SysUtils, DotEnv;

type
  TLogLevel = (llDebug, llInfo, llWarn, llError);

var
  Env: TDotEnv;
  
function ParseLogLevel(const S: string): TLogLevel;
var
  Normalized: string;
begin
  Normalized := LowerCase(S);
  if Normalized = 'debug' then
    Result := llDebug
  else if Normalized = 'warn' then
    Result := llWarn
  else if Normalized = 'warning' then
    Result := llWarn
  else if Normalized = 'error' then
    Result := llError
  else
    Result := llInfo;
end;

var
  Level: TLogLevel;
  LogFile: string;
  MaxSize: Integer;
begin
  Env := TDotEnv.Create;
  Env.LoadRequired;
  Env.ValidateSchemaRequired([
    TDotEnvSchemaItem.Create('APP_LOG_LEVEL'),
    TDotEnvSchemaItem.Create('APP_LOG_MAX_SIZE', dvkInteger),
    TDotEnvSchemaItem.Create('APP_LOG_ROTATE', dvkBoolean),
    TDotEnvSchemaItem.Create('APP_LOG_KEEP_FILES', dvkInteger)
  ]);

  Level := ParseLogLevel(Env.GetRequired('APP_LOG_LEVEL'));
  LogFile := Env.Get('APP_LOG_FILE', 'app.log');
  MaxSize := Env.GetIntRequired('APP_LOG_MAX_SIZE');

  case Level of
    llDebug: WriteLn('Log level: debug');
    llInfo: WriteLn('Log level: info');
    llWarn: WriteLn('Log level: warn');
    llError: WriteLn('Log level: error');
  end;
  WriteLn('Log format: ', Env.Get('APP_LOG_FORMAT', 'text'));
  WriteLn('Log file: ', LogFile);
  WriteLn('Max size: ', MaxSize, ' bytes');
  WriteLn('Rotation: ', Env.GetBoolRequired('APP_LOG_ROTATE'));
  WriteLn('Keep files: ', Env.GetIntRequired('APP_LOG_KEEP_FILES'));
end.
```

## Tips & Best Practices

1. **Use defaults intentionally** for non-critical configuration
2. **Validate early** — use aggregate typed validation at startup
3. **Use LoadForEnvironment** for conventional environment-specific overrides
4. **Never commit secrets** — use `.env.example` as a template
5. **Use interpolation** to build complex values from simple parts
6. **Test with LoadFromString** — no file I/O needed in tests
7. **Namespace common keys** — prefer `MYAPP_PORT` over `PORT`
8. **Use redacted diagnostics** — never print raw secret-bearing values

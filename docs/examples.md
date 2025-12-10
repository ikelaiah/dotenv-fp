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

Simple application with configuration:

**.env**
```bash
APP_NAME=MyApp
APP_VERSION=1.0.0
DEBUG=true
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
  
  if Env.GetBool('DEBUG', False) then
    WriteLn('Debug mode enabled');
end.
```

## Web Server Configuration

**.env**
```bash
# Server
HOST=0.0.0.0
PORT=8080
MAX_CONNECTIONS=100

# SSL
SSL_ENABLED=true
SSL_CERT_PATH=/etc/ssl/cert.pem
SSL_KEY_PATH=/etc/ssl/key.pem

# CORS
ALLOWED_ORIGINS=http://localhost:3000,https://myapp.com
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
  Env.Load;
  
  // Server settings
  Host := Env.Get('HOST', '127.0.0.1');
  Port := Env.GetInt('PORT', 3000);
  MaxConn := Env.GetInt('MAX_CONNECTIONS', 50);
  
  WriteLn('Server: ', Host, ':', Port);
  WriteLn('Max connections: ', MaxConn);
  
  // SSL configuration
  SSLEnabled := Env.GetBool('SSL_ENABLED', False);
  if SSLEnabled then
  begin
    WriteLn('SSL Certificate: ', Env.GetRequired('SSL_CERT_PATH'));
    WriteLn('SSL Key: ', Env.GetRequired('SSL_KEY_PATH'));
  end;
  
  // CORS origins
  Origins := Env.GetArray('ALLOWED_ORIGINS');
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
DB_PASSWORD=secret123
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
  Env.Load;
  
  // Validate required database config
  if not Env.Validate(['DB_HOST', 'DB_NAME', 'DB_USER', 'DB_PASSWORD']) then
  begin
    WriteLn('Error: Missing database configuration');
    Halt(1);
  end;
  
  // Use the interpolated URL
  WriteLn('Connecting to: ', Env.Get('DATABASE_URL'));
  
  // Or build manually
  WriteLn('Host: ', Env.Get('DB_HOST'));
  WriteLn('Port: ', Env.GetInt('DB_PORT', 5432));
  WriteLn('Database: ', Env.Get('DB_NAME'));
  WriteLn('Pool size: ', Env.GetInt('DB_POOL_SIZE', 5));
  WriteLn('Timeout: ', Env.GetInt('DB_TIMEOUT', 30), 's');
end.
```

## Multi-Environment Setup

**Project structure:**
```
project/
├── .env                 # Shared defaults (committed)
├── .env.local           # Local overrides (gitignored)
├── .env.development     # Development settings
├── .env.production      # Production settings
└── .env.test            # Test settings
```

**.env**
```bash
APP_NAME=MyApp
LOG_LEVEL=info
```

**.env.development**
```bash
DEBUG=true
LOG_LEVEL=debug
DATABASE_URL=postgresql://localhost/myapp_dev
```

**.env.production**
```bash
DEBUG=false
LOG_LEVEL=warn
# DATABASE_URL set via system environment
```

**app.pas**
```pascal
program MultiEnvApp;

{$mode objfpc}{$H+}{$J-}

uses
  SysUtils, DotEnv;

var
  Env: TDotEnv;
  Environment: string;
begin
  Env := TDotEnv.Create;
  
  // Determine environment
  Environment := GetEnvironmentVariable('APP_ENV');
  if Environment = '' then
    Environment := 'development';
  
  // Load files in order (later overrides earlier)
  Env.LoadMultiple([
    '.env',
    '.env.' + Environment,
    '.env.local'
  ]);
  
  WriteLn('Environment: ', Environment);
  WriteLn('Debug: ', Env.GetBool('DEBUG', False));
  WriteLn('Log level: ', Env.Get('LOG_LEVEL', 'info'));
end.
```

## Validation Pattern

Fail fast if required configuration is missing:

```pascal
program ValidatedApp;

{$mode objfpc}{$H+}{$J-}

uses
  Types, DotEnv;

var
  Env: TDotEnv;
  Missing: TStringDynArray;
  I: Integer;
  RequiredKeys: array[0..3] of string = (
    'DATABASE_URL',
    'SECRET_KEY', 
    'API_KEY',
    'SMTP_HOST'
  );
begin
  Env := TDotEnv.Create;
  Env.Load;
  
  // Check all required keys
  if not Env.Validate(RequiredKeys) then
  begin
    WriteLn('ERROR: Missing required configuration:');
    WriteLn;
    
    Missing := Env.GetMissing(RequiredKeys);
    for I := 0 to High(Missing) do
      WriteLn('  • ', Missing[I]);
    
    WriteLn;
    WriteLn('Please check your .env file.');
    Halt(1);
  end;
  
  WriteLn('Configuration validated successfully!');
  // Continue with application...
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
    'DATABASE_URL=postgresql://test/testdb' + LineEnding +
    'DEBUG=true' + LineEnding +
    'API_KEY=test-key-123';
  
  Env := TDotEnv.Create;
  Env.LoadFromString(MockConfig);
  
  // Run assertions
  Assert(Env.Get('DATABASE_URL') = 'postgresql://test/testdb');
  Assert(Env.GetBool('DEBUG') = True);
  Assert(Env.Get('API_KEY') = 'test-key-123');
  
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
FEATURE_NEW_UI=true
FEATURE_DARK_MODE=false
FEATURE_BETA_API=true
FEATURE_ANALYTICS=true

# A/B testing
AB_TEST_CHECKOUT=variant_b
AB_TEST_SIGNUP=control
```

```pascal
program FeatureFlags;

{$mode objfpc}{$H+}{$J-}

uses
  DotEnv;

var
  Env: TDotEnv;
begin
  Env := TDotEnv.Create;
  Env.Load;
  
  // Check features
  if Env.GetBool('FEATURE_NEW_UI', False) then
    WriteLn('Using new UI')
  else
    WriteLn('Using classic UI');
  
  if Env.GetBool('FEATURE_DARK_MODE', False) then
    WriteLn('Dark mode enabled');
  
  if Env.GetBool('FEATURE_BETA_API', False) then
    WriteLn('Beta API enabled');
  
  // A/B test variant
  case Env.Get('AB_TEST_CHECKOUT', 'control') of
    'control': WriteLn('Checkout: Control group');
    'variant_a': WriteLn('Checkout: Variant A');
    'variant_b': WriteLn('Checkout: Variant B');
  end;
end.
```

## Logging Configuration

**.env**
```bash
# Logging
LOG_LEVEL=debug
LOG_FORMAT=json
LOG_OUTPUT=file
LOG_FILE=/var/log/myapp.log
LOG_MAX_SIZE=10485760
LOG_ROTATE=true
LOG_KEEP_FILES=5
```

```pascal
program LoggingConfig;

{$mode objfpc}{$H+}{$J-}

uses
  DotEnv;

type
  TLogLevel = (llDebug, llInfo, llWarn, llError);
  TLogFormat = (lfText, lfJson);
  TLogOutput = (loConsole, loFile, loBoth);

var
  Env: TDotEnv;
  
function ParseLogLevel(const S: string): TLogLevel;
begin
  case LowerCase(S) of
    'debug': Result := llDebug;
    'info': Result := llInfo;
    'warn', 'warning': Result := llWarn;
    'error': Result := llError;
  else
    Result := llInfo;
  end;
end;

var
  Level: TLogLevel;
  LogFile: string;
  MaxSize: Int64;
begin
  Env := TDotEnv.Create;
  Env.Load;
  
  Level := ParseLogLevel(Env.Get('LOG_LEVEL', 'info'));
  LogFile := Env.Get('LOG_FILE', 'app.log');
  MaxSize := Env.GetInt('LOG_MAX_SIZE', 10 * 1024 * 1024);  // 10MB default
  
  WriteLn('Log level: ', Env.Get('LOG_LEVEL', 'info'));
  WriteLn('Log format: ', Env.Get('LOG_FORMAT', 'text'));
  WriteLn('Log file: ', LogFile);
  WriteLn('Max size: ', MaxSize, ' bytes');
  WriteLn('Rotation: ', Env.GetBool('LOG_ROTATE', True));
  WriteLn('Keep files: ', Env.GetInt('LOG_KEEP_FILES', 3));
end.
```

## Tips & Best Practices

1. **Always use defaults** for non-critical configuration
2. **Validate early** — check required config at startup
3. **Use LoadMultiple** for environment-specific overrides
4. **Never commit secrets** — use `.env.example` as a template
5. **Use interpolation** to build complex values from simple parts
6. **Test with LoadFromString** — no file I/O needed in tests

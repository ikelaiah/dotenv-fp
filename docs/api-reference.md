# 📖 API Reference

Complete reference for all types, methods, and functions in dotenv-fp.

## Table of Contents

- [Types](#types)
- [TDotEnv Record](#tdotenv-record)
- [TDotEnvOptions Record](#tdotenvoptions-record)
- [Global Helper Functions](#global-helper-functions)
- [Exceptions](#exceptions)

## Types

### TDotEnvPair

Key-value pair for environment variables.

```pascal
TDotEnvPair = record
  Key: string;
  Value: string;
end;
```

### TDotEnvPairArray

Array of key-value pairs.

```pascal
TDotEnvPairArray = array of TDotEnvPair;
```

### TStringDynArray

Array of strings (used for `GetArray`, `Keys`, `Values`, etc.). This type is provided by the standard `Types` unit.

```pascal
// From the Types unit:
TStringDynArray = array of AnsiString;
```

### TDotEnvValueKind and TDotEnvSchemaItem

`TDotEnvSchemaItem` describes a required value for aggregate validation.

```pascal
TDotEnvValueKind = (dvkString, dvkInteger, dvkBoolean, dvkFloat);

Rule := TDotEnvSchemaItem.Create('PORT', dvkInteger);
```

## TDotEnv Record

The main record for loading and accessing environment variables.

### Creation

#### `Create`

Creates a new TDotEnv instance with default options.

```pascal
class function Create: TDotEnv; static;
```

**Example:**
```pascal
var
  Env: TDotEnv;
begin
  Env := TDotEnv.Create;
  Env.Load;
end;
```

#### `CreateWithOptions`

Creates a new TDotEnv instance with custom options.

```pascal
class function CreateWithOptions(const AOptions: TDotEnvOptions): TDotEnv; static;
```

**Example:**
```pascal
var
  Env: TDotEnv;
  Options: TDotEnvOptions;
begin
  Options := TDotEnvOptions.Default;
  Options.Override := True;
  Env := TDotEnv.CreateWithOptions(Options);
end;
```

### Loading Methods

#### `Load`

Loads environment variables from a file.

```pascal
function Load(const APath: string = '.env'): Boolean;
```

**Parameters:**
- `APath`: Path to the `.env` file (default: `.env`)

**Returns:** `True` if file was loaded successfully

**Example:**
```pascal
Env.Load;                    // Load .env
Env.Load('.env.local');      // Load specific file
Env.Load('config/.env');     // Load from subdirectory
```

#### `LoadRequired`

Strictly loads a file and reports an absolute path, line number, offending key
or entry, and reason when loading fails. Existing `Load` behavior remains
permissive and backward compatible.

```pascal
function LoadRequired(const APath: string = '.env'): Boolean;
```

**Raises:** `EDotEnvFileNotFound`, `EDotEnvParseError`, or `EDotEnvException`

#### `LoadFromStream`

Loads environment variables from a stream.

```pascal
function LoadFromStream(AStream: TStream): Boolean;
```

**Example:**
```pascal
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create('.env', fmOpenRead);
  try
    Env.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;
```

#### `LoadFromString`

Loads environment variables from a string.

```pascal
function LoadFromString(const AContent: string): Boolean;
```

**Example:**
```pascal
Env.LoadFromString('KEY=value' + LineEnding + 'OTHER=test');
```

#### `LoadMultiple`

Loads multiple files in order (later files override earlier ones).

```pascal
function LoadMultiple(const APaths: array of string): Boolean;
```

**Example:**
```pascal
Env.LoadMultiple(['.env', '.env.local', '.env.development']);
```

#### `LoadForEnvironment`

Loads `.env`, followed by `.env.{environment}`. If the argument is empty, the
environment is read from `APP_ENV`, then `NODE_ENV`.

```pascal
function LoadForEnvironment(const AEnvironment: string = ''): Boolean;
```

### String Getters

#### `Get`

Gets a string value with optional default.

```pascal
function Get(const AKey: string; const ADefault: string = ''): string;
```

**Example:**
```pascal
Host := Env.Get('HOST');                 // Returns '' if missing
Host := Env.Get('HOST', 'localhost');    // Returns 'localhost' if missing
```

#### `GetRequired`

Gets a required string value. Raises exception if missing.

```pascal
function GetRequired(const AKey: string): string;
```

**Raises:** `EDotEnvMissingKey` if key doesn't exist

#### `GetOrPrompt`

Returns an existing value or interactively prompts for it and stores the
answer in memory. Call `Save` to persist it.

```pascal
function GetOrPrompt(const AKey, APrompt: string;
  const ADefault: string = ''): string;
```

### Integer Getters

#### `GetInt`

Gets an integer value with optional default.

```pascal
function GetInt(const AKey: string; const ADefault: Integer = 0): Integer;
```

**Example:**
```pascal
Port := Env.GetInt('PORT');          // Returns 0 if missing/invalid
Port := Env.GetInt('PORT', 3000);    // Returns 3000 if missing/invalid
```

#### `GetIntRequired`

Gets a required integer value.

```pascal
function GetIntRequired(const AKey: string): Integer;
```

**Raises:** `EDotEnvMissingKey` or `EDotEnvParseError`

### Boolean Getters

#### `GetBool`

Gets a boolean value with optional default.

```pascal
function GetBool(const AKey: string; const ADefault: Boolean = False): Boolean;
```

**Recognized values:**
- Truthy: `true`, `yes`, `1`, `on` (case-insensitive)
- Falsy: `false`, `no`, `0`, `off` (case-insensitive)

**Example:**
```pascal
Debug := Env.GetBool('DEBUG');           // Returns False if missing
Debug := Env.GetBool('DEBUG', True);     // Returns True if missing
```

#### `GetBoolRequired`

Gets a required boolean value.

```pascal
function GetBoolRequired(const AKey: string): Boolean;
```

**Raises:** `EDotEnvMissingKey` or `EDotEnvParseError`

### Float Getters

#### `GetFloat`

Gets a float value with optional default.

```pascal
function GetFloat(const AKey: string; const ADefault: Double = 0.0): Double;
```

**Example:**
```pascal
Rate := Env.GetFloat('RATE');            // Returns 0.0 if missing/invalid
Rate := Env.GetFloat('RATE', 0.5);       // Returns 0.5 if missing/invalid
```

#### `GetFloatRequired`

Gets a required float value.

```pascal
function GetFloatRequired(const AKey: string): Double;
```

### Array Getter

#### `GetArray`

Splits a value by separator into an array.

```pascal
function GetArray(const AKey: string; const ASeparator: string = ','): TStringDynArray;
```

**Example:**
```pascal
// HOSTS=localhost,127.0.0.1,example.com
Hosts := Env.GetArray('HOSTS');              // Split by comma

// TAGS=web;api;backend
Tags := Env.GetArray('TAGS', ';');           // Split by semicolon
```

### Utility Methods

#### `Has`

Checks if a key exists.

```pascal
function Has(const AKey: string): Boolean;
```

#### `Keys`

Returns all loaded keys.

```pascal
function Keys: TStringDynArray;
```

#### `Values`

Returns all loaded values.

```pascal
function Values: TStringDynArray;
```

#### `AsArray`

Returns all key-value pairs.

```pascal
function AsArray: TDotEnvPairArray;
```

#### `Count`

Returns the number of loaded variables.

```pascal
function Count: Integer;
```

#### `ToString`

Returns all loaded variables, including secrets. Do not write this value to
logs; prefer `ToRedactedString`.

```pascal
function ToString: string;
```

#### `ToRedactedString`

Returns debug output with common password, secret, token, credential, private
key, and API key values replaced by `[REDACTED]`.

```pascal
function ToRedactedString: string;
```

#### `LoadedFiles`

Returns list of files that were loaded.

```pascal
function LoadedFiles: TStringDynArray;
```

### Validation Methods

#### `Validate`

Checks if all required keys exist.

```pascal
function Validate(const ARequiredKeys: array of string): Boolean;
```

**Example:**
```pascal
if not Env.Validate(['DATABASE_URL', 'SECRET_KEY']) then
  Halt(1);
```

#### `GetMissing`

Returns list of missing keys from required set.

```pascal
function GetMissing(const ARequiredKeys: array of string): TStringDynArray;
```

**Example:**
```pascal
Missing := Env.GetMissing(['DATABASE_URL', 'SECRET_KEY', 'PORT']);
for I := 0 to High(Missing) do
  WriteLn('Missing: ', Missing[I]);
```

#### `ValidateSchema`

Checks all required keys and types, returning every problem together.

```pascal
function ValidateSchema(const ASchema: array of TDotEnvSchemaItem;
  out AErrors: TStringDynArray): Boolean;
```

#### `ValidateSchemaRequired`

Raises one `EDotEnvValidationError` containing every missing or incorrectly
typed value.

```pascal
procedure ValidateSchemaRequired(const ASchema: array of TDotEnvSchemaItem);
```

### Environment Methods

#### `SetToEnv`

Sets a value in this `TDotEnv` instance. It does not modify the OS environment.

```pascal
procedure SetToEnv(const AKey, AValue: string);
```

#### `GetFromEnv`

Gets a value directly from system environment.

```pascal
function GetFromEnv(const AKey: string; const ADefault: string = ''): string;
```

### File Methods

#### `Save`

Safely quotes and escapes all values, writes a same-directory temporary file,
then atomically replaces the destination.

```pascal
function Save(const APath: string = '.env'): Boolean;
```

#### `GenerateExample`

Creates an example file that retains keys, comments, and layout while removing
values.

```pascal
function GenerateExample(const ASourcePath: string = '.env';
  const ADestPath: string = '.env.example'): Boolean;
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `Options` | `TDotEnvOptions` | Read/write configuration options |
| `Loaded` | `Boolean` | Read-only, `True` if any file was loaded |

## TDotEnvOptions Record

Configuration options for loading.

### Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `Override` | `Boolean` | `False` | Override existing environment variables |
| `Interpolate` | `Boolean` | `True` | Enable `${VAR}` interpolation |
| `Encoding` | `string` | `'UTF-8'` | Reserved and currently ignored; use UTF-8 files |
| `Verbose` | `Boolean` | `False` | Print debug information with likely secrets redacted |
| `Prefix` | `string` | `''` | Prefix for all loaded keys |

### Methods

#### `Default`

Returns options with default values.

```pascal
class function Default: TDotEnvOptions; static;
```

## Global Helper Functions

Simple API for quick scripts.

#### `DotEnvLoad`

Loads a `.env` file into global state.

```pascal
function DotEnvLoad(const APath: string = '.env'): TDotEnv;
```

#### `DotEnvGet`

Gets a value from global state.

```pascal
function DotEnvGet(const AKey: string; const ADefault: string = ''): string;
```

#### `DotEnvSet`

Sets a value in global state.

```pascal
procedure DotEnvSet(const AKey, AValue: string);
```

**Example:**
```pascal
begin
  DotEnvLoad;
  WriteLn(DotEnvGet('DATABASE_URL'));
  WriteLn(DotEnvGet('PORT', '3000'));
end.
```

## Exceptions

### EDotEnvException

Base exception class.

### EDotEnvMissingKey

Raised when a required key is not found.

```pascal
try
  Env.GetRequired('MISSING');
except
  on E: EDotEnvMissingKey do
    WriteLn('Missing key: ', E.Message);
end;
```

### EDotEnvParseError

Raised when strict loading finds malformed syntax or a value cannot be parsed
to the requested type.

```pascal
try
  Env.GetIntRequired('NOT_A_NUMBER');
except
  on E: EDotEnvParseError do
    WriteLn('Parse error: ', E.Message);
end;
```

### EDotEnvFileNotFound

Raised when `LoadRequired` cannot find a file.

### EDotEnvValidationError

Raised by `ValidateSchemaRequired` with all missing and invalid values.

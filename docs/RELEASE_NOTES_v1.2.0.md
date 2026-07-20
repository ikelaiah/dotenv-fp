# Release Notes - 🌿dotenv-fp v1.2.0

**Release Date:** July 20, 2026

## 🚀 Overview

Version 1.2.0 focuses on reliable application startup, safer diagnostics, and dependable `.env` file round trips. It adds strict loading with actionable errors, aggregate typed schema validation, atomic saving, secret redaction, a five-minute newcomer example, and Windows/Linux continuous integration.

Existing applications can continue using the permissive `Load()` API. The stricter behavior is opt-in through `LoadRequired()` and the schema validation methods.

## ✨ New Features

### 1. 🚨 Strict Dotenv Loading

**Method:** `LoadRequired(const APath: string = '.env'): Boolean`

Strictly loads a dotenv file and raises an actionable exception when the file is missing or malformed.

**Key Benefits:**

- Reports the absolute file path
- Identifies the line number and offending key or entry
- Explains why parsing failed
- Keeps the existing permissive `Load()` behavior available

**Usage:**

```pascal
try
  Env.LoadRequired('.env');
except
  on E: EDotEnvException do
    WriteLn(E.Message);
end;
```

Depending on the failure, `LoadRequired()` raises `EDotEnvFileNotFound`, `EDotEnvParseError`, or `EDotEnvException`.

---

### 2. 🧭 Aggregate Typed Schema Validation

**Types and methods:**

- `TDotEnvSchemaItem`
- `ValidateSchema()`
- `ValidateSchemaRequired()`

Validate all required configuration values and their expected types in one pass. Supported types are string, integer, boolean, and float.

**Key Benefits:**

- Reports all missing and invalid values together
- Avoids repeated fix-and-restart cycles during application startup
- Provides both a Boolean API and an exception-based API
- Uses the same typed rules as dotenv-fp's required getters

**Usage:**

```pascal
Env.ValidateSchemaRequired([
  TDotEnvSchemaItem.Create('DATABASE_URL'),
  TDotEnvSchemaItem.Create('APP_PORT', dvkInteger),
  TDotEnvSchemaItem.Create('APP_DEBUG', dvkBoolean),
  TDotEnvSchemaItem.Create('REQUEST_TIMEOUT', dvkFloat)
]);
```

`ValidateSchemaRequired()` raises one `EDotEnvValidationError` containing every schema problem.

---

### 3. 🛡️ Redacted Diagnostics

**Method:** `ToRedactedString: string`

Produces diagnostic output while replacing values for likely secret keys with `[REDACTED]`.

```pascal
WriteLn(Env.ToRedactedString);
```

Verbose loading now applies the same protection so common password, token, secret, and API-key values are not printed in plaintext.

Redaction is a diagnostic safeguard, not a substitute for keeping real secrets out of source control and application logs.

---

### 4. 👋 Five-Minute Newcomer Example

A new `examples/hello-dotenv/` Lazarus project demonstrates the recommended startup flow:

1. Strictly load `.env`
2. Validate all required settings
3. Read typed values
4. Display actionable errors

The example uses namespaced `APP_PORT` and `APP_DEBUG` keys so unrelated process variables such as `PORT` and `DEBUG` cannot unexpectedly override it. A root `.env.example` provides a safe configuration template.

## 🔧 Reliability and Safety Improvements

### 💾 Atomic, Escaped Saving

`Save()` now:

- Quotes and escapes every value
- Writes to a same-directory temporary file
- Atomically replaces the destination
- Preserves spaces, `#`, quotes, backslashes, control characters, and interpolation-like text across save/load round trips

```pascal
Env.SetToEnv('MESSAGE', 'A value with spaces and # characters');
Env.Save('.env');
Env.LoadRequired('.env');
```

### 🧩 Parsing and Type Safety

- Multiline double-quoted values no longer truncate at escaped quotes
- Single-quoted values are treated as literals and do not interpolate variables
- Empty `${}` interpolation resolves to an empty string instead of querying the operating system with an empty variable name
- The empty-interpolation fix prevents hidden Windows drive-current-directory entries, such as `::=::\`, from leaking into parsed values
- `GetBoolRequired()` now rejects unrecognized Boolean values instead of silently treating them as `False`

### 🧭 Clearer Environment Semantics

Documentation now distinguishes dotenv-fp's in-memory values from operating-system environment variables. `SetToEnv()` updates the current `TDotEnv` instance; it does not modify the parent process environment.

## 🔄 Continuous Integration

The project now validates every change on both Windows and Linux. CI builds and checks:

- The Lazarus package
- The complete FPCUnit test suite
- All five Lazarus examples
- The newcomer example with hostile generic `PORT` and `DEBUG` process variables

## ✅ Testing

- ✅ FPC 3.2.2: 121 tests, 0 errors, 0 failures
- ✅ Lazarus package build passes
- ✅ All five Lazarus examples build and run successfully
- ✅ Newcomer smoke test passes with `PORT=not-an-integer` and `DEBUG=release`
- ✅ Windows and Linux CI coverage
- ✅ No new runtime dependencies

## 📚 Documentation Updates

- ✅ README updated with strict loading, schema validation, safe saving, and redacted diagnostics
- ✅ API reference updated for the new types, methods, and exceptions
- ✅ Getting-started and configuration guides updated
- ✅ Root `.env.example` added
- ✅ Package metadata and changelog updated for version 1.2.0

## 🔀 Migration Guide

### From v1.1.0 to v1.2.0

No APIs were removed, and existing `Load()` calls remain permissive. Existing applications can upgrade without changing their loading code.

For stricter application startup, replace:

```pascal
Env.Load('.env');
```

with:

```pascal
Env.LoadRequired('.env');
Env.ValidateSchemaRequired([
  TDotEnvSchemaItem.Create('DATABASE_URL'),
  TDotEnvSchemaItem.Create('APP_PORT', dvkInteger),
  TDotEnvSchemaItem.Create('APP_DEBUG', dvkBoolean)
]);
```

Review these behavior refinements when upgrading:

- `GetBoolRequired()` now raises an error for values other than `true`, `false`, `yes`, `no`, `1`, `0`, `on`, or `off`
- Single-quoted values no longer interpolate; use double quotes when interpolation is intended
- Files written by `Save()` are consistently quoted and escaped, although loading them returns the original values

## 🔐 Security Recommendations

1. Never commit `.env` files containing real credentials
2. Commit `.env.example` with safe placeholders or empty values
3. Keep `.env*` ignored except for approved example files
4. Prefer `ToRedactedString()` over raw values when troubleshooting
5. Use a dedicated secret manager for production credentials

---

**Thank you for using dotenv-fp!** 🎉

For issues or suggestions, please visit: https://github.com/ikelaiah/dotenv-fp

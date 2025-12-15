# 🌿 dotenv-fp

> **Load environment variables from `.env` files in Free Pascal — the easy way!**

A feature-rich dotenv library for **Free Pascal 3.2.2+** inspired by [python-dotenv](https://github.com/theskumar/python-dotenv). Perfect for managing configuration in your Pascal applications without hardcoding sensitive data.

[![License: MIT](https://img.shields.io/badge/License-MIT-1E3A8A.svg)](https://opensource.org/licenses/MIT)
[![Free Pascal](https://img.shields.io/badge/Free%20Pascal-3.2.2+-3B82F6.svg)](https://www.freepascal.org/)
[![Lazarus](https://img.shields.io/badge/Lazarus-4.0+-60A5FA.svg)](https://www.lazarus-ide.org/)
![Supports Windows](https://img.shields.io/badge/support-Windows-F59E0B?logo=Windows)
![Supports Linux](https://img.shields.io/badge/support-Linux-F59E0B?logo=Linux)
[![Version](https://img.shields.io/badge/version-1.1.0-8B5CF6.svg)](CHANGELOG.md)
![No Dependencies](https://img.shields.io/badge/dependencies-none-10B981.svg)
[![Documentation](https://img.shields.io/badge/Docs-Available-brightgreen.svg)](docs/)
[![Status](https://img.shields.io/badge/Status-Stable-brightgreen.svg)]()

## ✨ Features

| Feature | Description |
|---------|-------------|
| 📁 **Load `.env` files** | Read configuration from `.env` files |
| 🔗 **Variable interpolation** | Use `${VAR}` or `$VAR` syntax to reference other variables |
| 📝 **Multi-line values** | Support for values spanning multiple lines |
| 🎯 **Quoted values** | Single quotes, double quotes, or unquoted |
| 💬 **Comments** | Use `#` for comments (line or inline) |
| 🐚 **Shell compatible** | Supports `export` prefix for shell compatibility |
| 🔒 **Type-safe getters** | `GetInt()`, `GetBool()`, `GetFloat()`, `GetArray()` |
| ⚡ **Default values** | Fallback values when keys are missing |
| ✅ **Validation** | Check for required variables before running |
| 📚 **Multiple files** | Load `.env`, `.env.local`, `.env.production`, etc. |
| 🌍 **Environment-aware** | Auto-load `.env.{environment}` files (v1.1.0+) |
| 💾 **Save to file** | Generate `.env` files programmatically (v1.1.0+) |
| 📋 **Generate examples** | Create `.env.example` for version control (v1.1.0+) |
| 💬 **Interactive prompts** | `GetOrPrompt()` for first-run setup (v1.1.0+) |
| 🏷️ **Key prefixing** | Add prefixes like `APP_` to all loaded keys |
| 🧹 **Zero memory leaks** | Uses advanced records — no manual `Free` calls! |
| 📦 **Zero dependencies** | Only standard FPC units |

## 🚀 Quick Start

### Installation

1. Copy `src/DotEnv.pas` to your project  
   *— or add the `src` folder to your unit search path*
2. Add `DotEnv` to your `uses` clause

That's it! No package manager needed. 🎉

### Your First `.env` File

Create a `.env` file in your project root:

```bash
# Database settings
DATABASE_URL=postgresql://localhost/mydb
DB_POOL_SIZE=10

# Server configuration  
PORT=3000
DEBUG=true

# Secrets (never commit these!)
SECRET_KEY="super-secret-key-here"
```

### Load It in Pascal

```pascal
program MyApp;

{$mode objfpc}{$H+}{$J-}

uses
  DotEnv;

var
  Env: TDotEnv;
begin
  // Create and load .env file
  Env := TDotEnv.Create;
  Env.Load;  // Loads .env from current directory
  
  // Read values with type safety
  WriteLn('Database: ', Env.Get('DATABASE_URL'));
  WriteLn('Port: ', Env.GetInt('PORT', 3000));
  WriteLn('Debug mode: ', Env.GetBool('DEBUG', False));
  WriteLn('Pool size: ', Env.GetInt('DB_POOL_SIZE', 5));
  
  // No need to free - advanced records clean up automatically!
end.
```

## 📖 `.env` File Format

```bash
# 💬 Comments start with #
# Empty lines are ignored

# Simple key-value pairs
DATABASE_URL=postgresql://localhost/mydb
PORT=3000
DEBUG=true

# 🎯 Quoted values (preserves spaces and special chars)
SECRET_KEY="my-secret-key"
MESSAGE='Hello, World!'
GREETING="Welcome to the app!"

# 🔗 Variable interpolation
BASE_URL=https://api.example.com
API_ENDPOINT=${BASE_URL}/v1/users
FULL_URL=$BASE_URL/health

# 📝 Multi-line values (use quotes)
PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
...more lines...
-----END RSA PRIVATE KEY-----"

# 🐚 Shell-compatible export syntax
export SHELL_VAR=works_in_bash_too

# 📋 Arrays (comma-separated, parsed with GetArray)
ALLOWED_HOSTS=localhost,127.0.0.1,example.com
FEATURES=auth,logging,cache
```

## 📚 API Reference

### Creating and Loading

```pascal
var
  Env: TDotEnv;
  Options: TDotEnvOptions;
begin
  // 🟢 Simple usage
  Env := TDotEnv.Create;
  Env.Load;                    // Load .env
  Env.Load('.env.local');      // Load specific file
  
  // 🟡 With options
  Options := TDotEnvOptions.Default;
  Options.Override := True;    // Override existing env vars
  Options.Verbose := True;     // Print debug info  
  Options.Prefix := 'APP_';    // Prefix all keys with APP_
  
  Env := TDotEnv.CreateWithOptions(Options);
  Env.Load;
  
  // 🔵 Load multiple files (later files override earlier ones)
  Env.LoadMultiple(['.env', '.env.local', '.env.development']);

  // 🟣 Load from string (great for testing!)
  Env.LoadFromString('KEY=value' + LineEnding + 'OTHER=test');

  // 🌍 NEW in v1.1.0: Environment-aware loading
  Env.LoadForEnvironment('production');   // Loads .env + .env.production
  Env.LoadForEnvironment();               // Auto-detects from APP_ENV or NODE_ENV
end;
```

### Getting Values

```pascal
// 📝 Strings
Env.Get('KEY');                    // Returns '' if missing
Env.Get('KEY', 'default');         // Returns 'default' if missing
Env.GetRequired('KEY');            // Raises exception if missing

// 🔢 Integers  
Env.GetInt('PORT');                // Returns 0 if missing/invalid
Env.GetInt('PORT', 3000);          // Returns 3000 if missing/invalid
Env.GetIntRequired('PORT');        // Raises exception if missing/invalid

// ✅ Booleans (recognizes: true/false, yes/no, 1/0, on/off)
Env.GetBool('DEBUG');              // Returns False if missing
Env.GetBool('DEBUG', True);        // Returns True if missing
Env.GetBoolRequired('DEBUG');      // Raises exception if missing

// 🔬 Floats
Env.GetFloat('RATE');              // Returns 0.0 if missing/invalid
Env.GetFloat('RATE', 0.5);         // Returns 0.5 if missing/invalid
Env.GetFloatRequired('RATE');      // Raises exception if missing/invalid

// 📋 Arrays (splits comma-separated values)
Hosts := Env.GetArray('ALLOWED_HOSTS');        // Split by comma
Tags := Env.GetArray('TAGS', ';');             // Split by semicolon

// 💬 NEW in v1.1.0: Interactive prompts (for setup scripts)
DbUrl := Env.GetOrPrompt('DATABASE_URL',
                        'Enter database URL',
                        'postgres://localhost/mydb');
// Prompts user if DATABASE_URL is missing, uses existing value if present
```

### Validation

```pascal
var
  Missing: TStringDynArray;
  I: Integer;
begin
  // ✅ Check if all required keys exist
  if Env.Validate(['DATABASE_URL', 'SECRET_KEY', 'PORT']) then
    WriteLn('All required configuration present!')
  else
  begin
    // 📋 Get list of missing keys
    Missing := Env.GetMissing(['DATABASE_URL', 'SECRET_KEY', 'PORT']);
    WriteLn('Missing configuration:');
    for I := 0 to High(Missing) do
      WriteLn('  - ', Missing[I]);
    Halt(1);
  end;
end;
```

### Utilities

```pascal
// 🔍 Check if key exists
if Env.Has('OPTIONAL_FEATURE') then
  EnableFeature;

// 📋 Get all keys and values
Keys := Env.Keys;           // TStringDynArray of all key names
Values := Env.Values;       // TStringDynArray of all values  
Pairs := Env.AsArray;       // TDotEnvPairArray with Key/Value records

// 🔢 Count loaded variables
WriteLn('Loaded ', Env.Count, ' environment variables');

// 🐛 Debug output (shows all loaded key=value pairs)
WriteLn(Env.ToString);

// 📁 See which files were loaded
for I := 0 to High(Env.LoadedFiles) do
  WriteLn('Loaded: ', Env.LoadedFiles[I]);
```

### File Operations (v1.1.0+)

```pascal
// 💾 Save environment variables to a file
Env := TDotEnv.Create;
Env.SetToEnv('DATABASE_URL', 'postgres://localhost/mydb');
Env.SetToEnv('PORT', '3000');
Env.SetToEnv('DEBUG', 'true');
Env.Save('.env');  // Writes to .env file

// 📋 Generate .env.example for version control
Env.Load('.env');
Env.GenerateExample('.env', '.env.example');
// Creates .env.example with keys but empty values

// 🌍 Environment-aware loading pattern
Env := TDotEnv.Create;
Env.LoadForEnvironment('development');   // Loads .env + .env.development
Env.LoadForEnvironment('production');    // Loads .env + .env.production
Env.LoadForEnvironment();                // Auto-detects from APP_ENV/NODE_ENV

// 💬 Interactive setup script example
Env := TDotEnv.Create;
Env.Load('.env');  // Try to load existing config
DbUrl := Env.GetOrPrompt('DATABASE_URL',
                        'Enter database URL',
                        'postgres://localhost/mydb');
Port := Env.GetOrPrompt('PORT', 'Enter port', '3000');
Env.Save('.env');  // Save the configuration
WriteLn('Configuration saved!');
```

### Global Helpers (Simple API)

For quick scripts or simple applications:

```pascal
uses DotEnv;

begin
  DotEnvLoad;                              // Load .env
  DotEnvLoad('.env.local');                // Load specific file
  
  WriteLn(DotEnvGet('DATABASE_URL'));      // Get value
  WriteLn(DotEnvGet('PORT', '3000'));      // Get with default
  
  DotEnvSet('RUNTIME_VAR', 'value');       // Set at runtime
end.
```

## 🔗 Variable Interpolation

Reference other variables using `${VAR}` or `$VAR` syntax:

```bash
# Define base values
APP_NAME=MyAwesomeApp
APP_VERSION=1.0.0
BASE_URL=https://api.example.com

# Reference them in other values
APP_TITLE=${APP_NAME} v${APP_VERSION}
API_USERS=${BASE_URL}/users
API_HEALTH=$BASE_URL/health

# Also works with system environment variables!
HOME_CONFIG=${HOME}/.myapp/config
```

**Resolution order:**
1. Variables defined earlier in the same `.env` file
2. System environment variables

## ⚙️ Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Override` | `Boolean` | `False` | Override existing system environment variables |
| `Interpolate` | `Boolean` | `True` | Enable `${VAR}` variable interpolation |
| `Verbose` | `Boolean` | `False` | Print debug info while loading |
| `Prefix` | `String` | `''` | Add prefix to all loaded key names |

```pascal
var
  Options: TDotEnvOptions;
begin
  Options := TDotEnvOptions.Default;  // Start with defaults
  Options.Override := True;
  Options.Prefix := 'MYAPP_';
  
  Env := TDotEnv.CreateWithOptions(Options);
  Env.Load;
  
  // KEY=value in .env becomes accessible as MYAPP_KEY
  WriteLn(Env.Get('MYAPP_KEY'));
end;
```

## ⚠️ Error Handling

```pascal
uses DotEnv;

var
  Env: TDotEnv;
begin
  Env := TDotEnv.Create;
  Env.Load;
  
  // 🔴 Handle missing required keys
  try
    Env.GetRequired('MISSING_KEY');
  except
    on E: EDotEnvMissingKey do
      WriteLn('Configuration error: ', E.Message);
  end;
  
  // 🔴 Handle invalid type conversions
  try
    Env.GetIntRequired('NOT_A_NUMBER');
  except
    on E: EDotEnvParseError do
      WriteLn('Parse error: ', E.Message);
  end;
end.
```

## 🆚 Comparison with Python dotenv

dotenv-fp is inspired by [python-dotenv](https://github.com/theskumar/python-dotenv) and provides equivalent core functionality, plus additional features suited for statically-typed Pascal development:

| Feature | python-dotenv | dotenv-fp |
|---------|:-------------:|:---------:|
| Load .env file | ✅ | ✅ |
| Variable interpolation | ✅ | ✅ |
| Multi-line values | ✅ | ✅ |
| Quoted values | ✅ | ✅ |
| Export prefix | ✅ | ✅ |
| Comments | ✅ | ✅ |
| Override mode | ✅ | ✅ |
| **Type-safe getters** | — | ✅ |
| **Built-in validation** | — | ✅ |
| **Array parsing** | — | ✅ |
| **Key prefixing** | — | ✅ |
| **Automatic memory management** | N/A | ✅ |

## 🧪 Running Tests

The library includes a comprehensive test suite using FPCUnit:

```bash
cd tests
fpc TestRunner.pas
./TestRunner -a --format=plain
```

Expected output:
```
Time:00.075 N:96 E:0 F:0 I:0
  TTestDotEnv Time:00.075 N:96 E:0 F:0 I:0
    00.000  Test01_BasicParsing_SimpleKeyValue
    00.000  Test02_BasicParsing_TrimmedValue
    ...
Number of run tests: 96
Number of errors:    0
Number of failures:  0
```

## 📁 Project Structure

```
dotenv-fp/
├── src/
│   └── DotEnv.pas          # Main library unit
├── tests/
│   ├── TestRunner.pas      # FPCUnit test runner
│   └── DotEnv.Test.pas     # Test cases
├── examples/
│   ├── basic/              # Basic usage example
│   └── advanced/           # Advanced features example
├── docs/                   # Documentation
├── .env.example            # Example .env file
├── CHANGELOG.md
└── README.md
```

## 💡 Tips for New Free Pascal Developers

1. **Advanced Records**: This library uses advanced records (`{$modeswitch advancedrecords}`), which means you don't need to call `.Free` — memory is managed automatically!

2. **Mode ObjFPC**: Make sure your program uses `{$mode objfpc}{$H+}{$J-}` for compatibility.

3. **String Handling**: The `{$H+}` switch enables long strings (AnsiString) by default, which this library requires.

4. **File Paths**: Use forward slashes `/` or the `PathDelim` constant for cross-platform compatibility.

## 🤝 Contributing

Contributions are welcome! Feel free to:

- 🐛 Report bugs
- 💡 Suggest features  
- 🔧 Submit pull requests

## 📄 License

MIT License — See [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [python-dotenv](https://github.com/theskumar/python-dotenv)
- Built for the awesome Free Pascal community

---

**Happy coding! 🚀**

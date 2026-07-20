# 💡 Runnable Examples

The projects under [`examples/`](../examples/) are the source of truth for
executable dotenv-fp examples. This page is a catalog and learning path; it
does not duplicate complete Pascal programs that can drift away from the files
compiled by CI.

Library behavior itself is defined by [`src/DotEnv.pas`](../src/DotEnv.pas)
and verified by the [`tests/`](../tests/) suite.

## 🌱 Start Here: Hello dotenv-fp

Beginners should start with
[`examples/hello-dotenv/hello_dotenv.pas`](../examples/hello-dotenv/hello_dotenv.pas).
It demonstrates the recommended application startup sequence:

1. Load a required dotenv file with actionable errors
2. Validate every required key and type together
3. Read values with required typed getters
4. Catch `EDotEnvException` and exit cleanly

From the repository root:

```bash
cp .env.example .env
bash ./build-examples.sh
./examples-bin/hello_dotenv
```

Windows PowerShell:

```powershell
Copy-Item .env.example .env
./build-examples.ps1
.\examples-bin\hello_dotenv.exe
```

See the [hello example README](../examples/hello-dotenv/README.md) for expected
output and an explanation of its namespaced `APP_` keys.

## 📚 Learning Path

### 1. Basic API Tour

- **Source:** [`basic_example.pas`](../examples/basic/basic_example.pas)
- **Guide:** [`examples/basic/README.md`](../examples/basic/README.md)

Demonstrates:

- `LoadRequired()`
- `ValidateSchema()` with aggregate errors
- Required integer and Boolean getters
- Arrays and interpolation
- `ToRedactedString()` without exposing the configured secret

This example uses its own `.env.example`; copy it to `.env` and run the binary
from `examples/basic` as described in its README.

### 2. Advanced Configuration

- **Source:** [`advanced_example.pas`](../examples/advanced/advanced_example.pas)
- **Guide:** [`examples/advanced/README.md`](../examples/advanced/README.md)

Demonstrates:

- Custom `TDotEnvOptions` and key prefixing
- Required base configuration plus optional `.env.local` overrides
- Loading configuration directly from a string
- Interpolation and typed schema validation
- Inspecting keys and loaded file paths without printing secrets

### 3. Environment-aware Loading

- **Source:** [`environment_example.pas`](../examples/environment-aware/environment_example.pas)
- **Guide:** [`examples/environment-aware/README.md`](../examples/environment-aware/README.md)

Demonstrates explicit development and production loading with
`LoadForEnvironment()`, followed by `APP_ENV`/`NODE_ENV` auto-detection. The
example is self-contained: it creates non-secret files in a unique temporary
directory and removes them on exit.

### 4. Interactive Setup

- **Source:** [`setup_example.pas`](../examples/interactive-setup/setup_example.pas)
- **Guide:** [`examples/interactive-setup/README.md`](../examples/interactive-setup/README.md)

Demonstrates:

- Loading an existing local file strictly when present
- `GetOrPrompt()` with defaults
- Typed validation before saving
- Atomic `Save()`
- `GenerateExample()` for a committable template

Run this example from `examples/interactive-setup`. It creates local `.env`
and `.env.example` files there and never prints the configured database URL.

## 🔨 Build Outputs

Both build scripts discover the canonical Lazarus projects one directory below
`examples/`, build them in Release mode, and write executables to
`examples-bin/`:

```text
examples-bin/
├── advanced_example[.exe]
├── basic_example[.exe]
├── environment_example[.exe]
├── hello_dotenv[.exe]
├── setup_example[.exe]
└── units/
    └── <example>/
```

The output directory is generated and ignored by Git. CI runs the PowerShell
script on Windows and the shell script on Linux, so the documented build path
is continuously verified.

## 🛡️ Example Security Rules

- Commit `.env.example` templates, never real credentials
- Namespace common keys such as `PORT` and `DEBUG`
- Do not print passwords, tokens, private keys, or credential-bearing URLs
- Use `ToRedactedString()` for diagnostic output
- Use a secret manager or deployment environment variables in production

For API-level details, see the [API reference](api-reference.md). For dotenv
syntax, see the [syntax guide](syntax.md).

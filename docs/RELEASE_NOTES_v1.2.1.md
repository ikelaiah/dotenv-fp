# Release Notes - 🌿 dotenv-fp v1.2.1

**Release Date:** July 21, 2026

## 🚀 Overview

Version 1.2.1 is a documentation and example-reliability patch release. It
makes the runnable projects under [`examples/`](../examples/) the single
source of truth, brings every project up to the current safe usage guidance,
and adds one cross-platform command for building all examples into
`examples-bin/`.

The dotenv-fp API is unchanged from v1.2.0.

## 🌱 One Clear Beginner Path

Beginners should start with
[`examples/hello-dotenv/hello_dotenv.pas`](../examples/hello-dotenv/hello_dotenv.pas).
The new [`examples/README.md`](../examples/README.md) then provides an explicit
learning order:

1. `hello-dotenv` — strict startup and typed validation
2. `basic` — arrays, interpolation, and redacted diagnostics
3. `advanced` — prefixing, layered files, and in-memory configuration
4. `environment-aware` — `.env.{environment}` loading
5. `interactive-setup` — prompts, validation, saving, and template generation

[`docs/examples.md`](examples.md) is now a catalog linking to these projects
instead of a second collection of standalone programs that could drift out of
sync.

## 🔨 Reproducible Example Builds

Build all five Lazarus projects on Linux or macOS:

```bash
bash ./build-examples.sh
```

Build them on Windows PowerShell:

```powershell
./build-examples.ps1
```

Both scripts:

- Discover canonical `examples/*/*.lpi` projects one directory deep
- Build every project in Lazarus Release mode
- Place executables directly under `examples-bin/`
- Keep compiler units under `examples-bin/units/<example>/`
- Fail when a project or expected executable is missing
- Clean the generated output directory before rebuilding

The generated `examples-bin/` directory is ignored by Git.

## 🛡️ Safer Runnable Examples

- Basic and advanced configuration keys are namespaced to avoid common process
  environment collisions
- The basic example reports whether a secret exists and uses redacted
  diagnostics without printing the secret
- The advanced example no longer prints database URLs or other potentially
  credential-bearing values
- The interactive setup confirms that a database URL is configured without
  displaying it
- The environment-aware example uses non-secret values in a unique temporary
  directory and removes its files on exit
- Previously committed runtime `.env` files were removed; safe templates use
  `.env.example` names

## 🔄 Continuous Integration

Windows CI runs `build-examples.ps1`, and Linux CI runs `build-examples.sh`.
Both platforms smoke-test all five examples. CI supplies blank input to the
interactive setup, verifies that `.env` and `.env.example` are created, and
checks that the generated template contains no configured values.

## ✅ Validation

- FPC 3.2.2: 121 tests, 0 errors, 0 failures
- Lazarus package v1.2.1 build: pass
- Windows PowerShell example build script: all five projects pass
- POSIX shell script syntax check: pass
- Newcomer hostile-environment smoke test: pass
- All five example runtime smoke tests: pass
- Markdown links and code fences: pass
- `git diff --check`: pass

## 🔀 Migration from v1.2.0

No application code changes are required. The public API and runtime behavior
are unchanged.

Repository contributors should use the new build scripts instead of invoking
each example project manually. Built executables now live in `examples-bin/`
when using the documented workflow.

## 🔐 Security Reminder

Commit `.env.example` templates only. Keep real `.env` files ignored, avoid
printing credential-bearing configuration, and use a dedicated secret manager
for production credentials.

---

**Thank you for using dotenv-fp!** 🎉

For issues or suggestions, visit the
[dotenv-fp repository](https://github.com/ikelaiah/dotenv-fp).

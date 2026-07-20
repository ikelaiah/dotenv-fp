# Runnable Examples

The projects in this directory are the source of truth for executable
dotenv-fp examples. `docs/examples.md` is a catalog that links here; it does
not maintain separate copies of these programs.

## Beginner path

Start with [`hello-dotenv`](hello-dotenv/hello_dotenv.pas). It demonstrates the
recommended application startup sequence in the smallest complete program:

1. Strictly load the required dotenv file
2. Validate all required keys and types together
3. Read values with required typed getters
4. Report actionable configuration errors

Continue in this order:

| Example | Purpose |
|---------|---------|
| [`hello-dotenv`](hello-dotenv/hello_dotenv.pas) | Five-minute newcomer example |
| [`basic`](basic/basic_example.pas) | Core API tour, arrays, interpolation, and redaction |
| [`advanced`](advanced/advanced_example.pas) | Prefixing, layered files, and in-memory configuration |
| [`environment-aware`](environment-aware/environment_example.pas) | Self-contained `.env.{environment}` loading |
| [`interactive-setup`](interactive-setup/setup_example.pas) | Prompts, validation, atomic saving, and example generation |

## Build every example

Linux and macOS:

```bash
bash ./build-examples.sh
```

Windows PowerShell:

```powershell
./build-examples.ps1
```

Both scripts build the Lazarus projects in Release mode and place executables
in `examples-bin/`. Compiler units and objects stay under
`examples-bin/units/<example>/`. The entire output directory is ignored by Git.

Each example README explains its runtime configuration and working directory.

## Security

Committed example files contain placeholders or non-secret demonstration
values only. The programs never print configured passwords, tokens, secret
keys, or credential-bearing URLs. Use `.env.example` files for templates and
keep real `.env` files ignored.

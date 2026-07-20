# Advanced Example

This runnable example demonstrates prefixing, layered files, interpolation,
typed validation, in-memory loading, redacted diagnostics, and safe key
inspection.

Build all examples from the repository root:

```bash
bash ./build-examples.sh
```

On Windows PowerShell, use `./build-examples.ps1`. Then run:

```bash
cd examples/advanced
cp .env.example .env
# Optional: cp .env.local.example .env.local
../../examples-bin/advanced_example
```

On Windows, use `Copy-Item` and run
`..\..\examples-bin\advanced_example.exe`.

The example reports whether a password is configured but never prints it.

# Basic API Tour

This runnable example builds on `hello-dotenv` with arrays, interpolation,
aggregate typed validation, and redacted diagnostics. It never prints the
configured secret value.

From the repository root, build every example first:

```bash
bash ./build-examples.sh
```

On Windows PowerShell, use `./build-examples.ps1` instead. Then prepare and run
the example from its own directory:

```bash
cd examples/basic
cp .env.example .env
../../examples-bin/basic_example
```

On Windows, use `Copy-Item .env.example .env` and run
`..\..\examples-bin\basic_example.exe`.

The local `.env` file is ignored by Git. Keep real credentials out of committed
example files.

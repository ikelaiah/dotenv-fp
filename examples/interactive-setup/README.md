# Interactive Setup

This example demonstrates `GetOrPrompt()`, strict loading of an existing local
file, aggregate typed validation, atomic `Save()`, and `GenerateExample()`.

It intentionally creates `.env` and `.env.example` in its current directory.
Run it from `examples/interactive-setup`, where `.env` is ignored by Git:

```bash
bash ./build-examples.sh
cd examples/interactive-setup
../../examples-bin/setup_example
```

On Windows PowerShell:

```powershell
./build-examples.ps1
Set-Location examples/interactive-setup
..\..\examples-bin\setup_example.exe
```

The program asks for:

- `SETUP_APP_NAME`
- `SETUP_DATABASE_URL`
- `SETUP_PORT` as an integer
- `SETUP_DEBUG` as a recognized Boolean

The summary confirms that a database URL is configured without printing it.
Commit only the generated `.env.example`; never commit the local `.env` file.

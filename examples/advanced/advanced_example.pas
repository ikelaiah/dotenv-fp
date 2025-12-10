{
  Advanced Example - DotEnv for Free Pascal
  
  Demonstrates:
  - Custom options
  - Multiple file loading
  - Environment prefixing
  - Override behavior
  - Global helpers
}
program advanced_example;

{$mode objfpc}{$H+}{$J-}

uses
  SysUtils, Types, DotEnv;

var
  Env: TDotEnv;
  Options: TDotEnvOptions;
  Keys: TStringDynArray;
  I: Integer;
  
begin
  WriteLn('=== DotEnv Advanced Example ===');
  WriteLn;
  
  // Example 1: Custom options
  WriteLn('--- Custom Options ---');
  Options := TDotEnvOptions.Default;
  Options.Override := True;      // Override existing env vars
  Options.Verbose := True;       // Print debug info
  Options.Prefix := 'MYAPP_';    // Add prefix to all keys
  
  Env := TDotEnv.CreateWithOptions(Options);
  Env.Load('.env');
  
  // Keys will be prefixed with MYAPP_
  WriteLn('MYAPP_PORT: ', Env.Get('MYAPP_PORT', 'not set'));
  WriteLn;
  
  // Example 2: Multiple file loading (like .env.local, .env.development)
  WriteLn('--- Multiple Files ---');
  Env := TDotEnv.Create;
  Env.LoadMultiple(['.env', '.env.local']);
  
  WriteLn('Loaded files:');
  for I := 0 to High(Env.LoadedFiles) do
    WriteLn('  - ', Env.LoadedFiles[I]);
  WriteLn;
  
  // Example 3: Load from string (useful for testing)
  WriteLn('--- Load from String ---');
  Env := TDotEnv.Create;
  Env.LoadFromString(
    'TEST_VAR=hello' + LineEnding +
    'TEST_NUM=42' + LineEnding +
    'TEST_BOOL=true'
  );
  
  WriteLn('TEST_VAR: ', Env.Get('TEST_VAR'));
  WriteLn('TEST_NUM: ', Env.GetInt('TEST_NUM'));
  WriteLn('TEST_BOOL: ', Env.GetBool('TEST_BOOL'));
  WriteLn;
  
  // Example 4: Using global helpers (simple API)
  WriteLn('--- Global Helpers ---');
  DotEnvLoad('.env');
  WriteLn('Using global: ', DotEnvGet('DATABASE_URL', 'not set'));
  
  DotEnvSet('RUNTIME_VAR', 'set at runtime');
  WriteLn('Runtime var: ', DotEnvGet('RUNTIME_VAR'));
  WriteLn;
  
  // Example 5: Iterate all keys
  WriteLn('--- All Keys ---');
  Env := TDotEnv.Create;
  Env.Load('.env');
  
  Keys := Env.Keys;
  for I := 0 to High(Keys) do
    WriteLn('  ', Keys[I], ' = ', Env.Get(Keys[I]));
  
  WriteLn;
  WriteLn('Total variables loaded: ', Env.Count);
  
  WriteLn;
  WriteLn('Done!');
end.

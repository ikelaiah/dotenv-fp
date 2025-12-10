(*
  Basic Example - DotEnv for Free Pascal
  
  This example demonstrates the main features of the dotenv-fp library.
  
  Create a .env file in the same directory with:
  
  DATABASE_URL=postgresql://localhost/mydb
  PORT=3000
  DEBUG=true
  SECRET_KEY="my-secret-key"
  ALLOWED_HOSTS=localhost,127.0.0.1,example.com
  APP_NAME=MyApp
  GREETING="Hello, ${APP_NAME}!"
*)
program basic_example;

{$mode objfpc}{$H+}{$J-}

uses
  SysUtils, Types, DotEnv;

var
  Env: TDotEnv;
  Hosts: TStringDynArray;
  I: Integer;
  Missing: TStringDynArray;
  
begin
  WriteLn('=== DotEnv Basic Example ===');
  WriteLn;
  
  // Create and load
  Env := TDotEnv.Create;
  
  if not Env.Load('.env') then
  begin
    WriteLn('Warning: .env file not found, using defaults');
  end;
  
  // Basic string getter
  WriteLn('DATABASE_URL: ', Env.Get('DATABASE_URL', 'not set'));
  
  // Integer getter with default
  WriteLn('PORT: ', Env.GetInt('PORT', 8080));
  
  // Boolean getter
  WriteLn('DEBUG: ', Env.GetBool('DEBUG', False));
  
  // Array getter (comma-separated)
  WriteLn('ALLOWED_HOSTS:');
  Hosts := Env.GetArray('ALLOWED_HOSTS');
  for I := 0 to High(Hosts) do
    WriteLn('  - ', Hosts[I]);
  
  // Variable interpolation
  WriteLn('GREETING: ', Env.Get('GREETING'));
  
  // Check if key exists
  WriteLn('Has SECRET_KEY: ', Env.Has('SECRET_KEY'));
  
  // Validation example
  WriteLn;
  WriteLn('=== Validation ===');
  if Env.Validate(['DATABASE_URL', 'PORT', 'NONEXISTENT']) then
    WriteLn('All required keys present')
  else
  begin
    WriteLn('Missing required keys:');
    Missing := Env.GetMissing(['DATABASE_URL', 'PORT', 'NONEXISTENT']);
    for I := 0 to High(Missing) do
      WriteLn('  - ', Missing[I]);
  end;
  
  // Using required getter (will raise exception if missing)
  WriteLn;
  WriteLn('=== Required Getter ===');
  try
    WriteLn('SECRET_KEY: ', Env.GetRequired('SECRET_KEY'));
  except
    on E: EDotEnvMissingKey do
      WriteLn('Error: ', E.Message);
  end;
  
  // Show all loaded values
  WriteLn;
  WriteLn('=== All Loaded Values ===');
  WriteLn(Env.ToString);
  
  WriteLn;
  WriteLn('Done!');
end.

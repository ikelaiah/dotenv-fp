program advanced_example;

{$mode objfpc}{$H+}{$J-}

uses
  Types, DotEnv;

var
  Env: TDotEnv;
  Options: TDotEnvOptions;
  Errors, Keys: TStringDynArray;
  I: Integer;

begin
  WriteLn('=== dotenv-fp Advanced Example ===');
  WriteLn;

  try
    WriteLn('--- Prefixing and redacted verbose-safe data ---');
    Options := TDotEnvOptions.Default;
    Options.Override := True;
    Options.Prefix := 'ADV_PREFIXED_';
    Env := TDotEnv.CreateWithOptions(Options);
    Env.LoadFromString(
      'PORT=4100' + LineEnding +
      'DEBUG=true' + LineEnding +
      'API_TOKEN=replace-locally'
    );
    WriteLn('Prefixed port: ', Env.GetIntRequired('ADV_PREFIXED_PORT'));
    WriteLn(Env.ToRedactedString);
    WriteLn;

    WriteLn('--- Layered files ---');
    Env := TDotEnv.Create;
    Env.LoadRequired('.env');
    Env.Load('.env.local');  // Optional machine-specific overrides.

    if not Env.ValidateSchema([
      TDotEnvSchemaItem.Create('ADV_APP_NAME'),
      TDotEnvSchemaItem.Create('ADV_PORT', dvkInteger),
      TDotEnvSchemaItem.Create('ADV_DEBUG', dvkBoolean),
      TDotEnvSchemaItem.Create('ADV_API_ENDPOINT'),
      TDotEnvSchemaItem.Create('ADV_DATABASE_PASSWORD')
    ], Errors) then
    begin
      WriteLn(StdErr, 'Configuration needs attention:');
      for I := 0 to High(Errors) do
        WriteLn(StdErr, '  - ', Errors[I]);
      Halt(1);
    end;

    WriteLn('Application: ', Env.GetRequired('ADV_APP_NAME'));
    WriteLn('Port: ', Env.GetIntRequired('ADV_PORT'));
    WriteLn('Debug: ', Env.GetBoolRequired('ADV_DEBUG'));
    WriteLn('API endpoint: ', Env.GetRequired('ADV_API_ENDPOINT'));
    WriteLn('Database password configured: ', Env.Has('ADV_DATABASE_PASSWORD'));

    WriteLn('Loaded files:');
    for I := 0 to High(Env.LoadedFiles) do
      WriteLn('  - ', Env.LoadedFiles[I]);
    WriteLn;

    WriteLn('--- Load from a string ---');
    Env := TDotEnv.Create;
    Env.LoadFromString(
      'ADV_TEST_NAME=inline' + LineEnding +
      'ADV_TEST_COUNT=42' + LineEnding +
      'ADV_TEST_ENABLED=true'
    );
    WriteLn('Name: ', Env.GetRequired('ADV_TEST_NAME'));
    WriteLn('Count: ', Env.GetIntRequired('ADV_TEST_COUNT'));
    WriteLn('Enabled: ', Env.GetBoolRequired('ADV_TEST_ENABLED'));
    WriteLn;

    WriteLn('--- Loaded keys, without values ---');
    Keys := Env.Keys;
    for I := 0 to High(Keys) do
      WriteLn('  - ', Keys[I]);
  except
    on E: EDotEnvException do
    begin
      WriteLn(StdErr, 'dotenv-fp error: ', E.Message);
      Halt(1);
    end;
  end;
end.

program environment_example;

{$mode objfpc}{$H+}{$J-}

uses
  Classes, SysUtils, Types, DotEnv;

const
  DemoFileNames: array[0..2] of string = (
    '.env', '.env.development', '.env.production'
  );

procedure WriteDemoFile(const APath: string; const ALines: array of string);
var
  Lines: TStringList;
  I: Integer;
begin
  Lines := TStringList.Create;
  try
    for I := Low(ALines) to High(ALines) do
      Lines.Add(ALines[I]);
    Lines.SaveToFile(APath);
  finally
    Lines.Free;
  end;
end;

procedure CreateDemoFiles;
begin
  WriteDemoFile('.env', [
    '# Base non-secret configuration',
    'DEMO_APP_NAME=Environment-aware App',
    'DEMO_PORT=3000',
    'DEMO_DEBUG=false',
    'DEMO_LOG_LEVEL=info'
  ]);
  WriteDemoFile('.env.development', [
    '# Development overrides',
    'DEMO_DEBUG=true',
    'DEMO_LOG_LEVEL=verbose'
  ]);
  WriteDemoFile('.env.production', [
    '# Production overrides',
    'DEMO_PORT=8080',
    'DEMO_DEBUG=false',
    'DEMO_LOG_LEVEL=error'
  ]);
end;

function CreateDemoDirectory: string;
var
  BaseDir: string;
begin
  BaseDir := IncludeTrailingPathDelimiter(GetTempDir(False));
  repeat
    Result := BaseDir + 'dotenv-fp-environment-' + IntToHex(Random(MaxInt), 8);
  until not DirectoryExists(Result);
  if not ForceDirectories(Result) then
    raise Exception.CreateFmt('Unable to create demo directory: %s', [Result]);
end;

procedure RemoveDemoDirectory(const APath: string);
var
  I: Integer;
  FilePath: string;
begin
  for I := Low(DemoFileNames) to High(DemoFileNames) do
  begin
    FilePath := IncludeTrailingPathDelimiter(APath) + DemoFileNames[I];
    if FileExists(FilePath) then
      DeleteFile(FilePath);
  end;
  if DirectoryExists(APath) then
    RemoveDir(APath);
end;

procedure DemonstrateEnvironment(const AEnvironment: string);
var
  Env: TDotEnv;
  Options: TDotEnvOptions;
  Files: TStringDynArray;
  I: Integer;
begin
  Options := TDotEnvOptions.Default;
  Options.Override := True;  // Keep the self-contained demo deterministic.
  Env := TDotEnv.CreateWithOptions(Options);

  if not Env.LoadForEnvironment(AEnvironment) then
    raise EDotEnvException.Create('Unable to load the demo configuration');

  Env.ValidateSchemaRequired([
    TDotEnvSchemaItem.Create('DEMO_APP_NAME'),
    TDotEnvSchemaItem.Create('DEMO_PORT', dvkInteger),
    TDotEnvSchemaItem.Create('DEMO_DEBUG', dvkBoolean),
    TDotEnvSchemaItem.Create('DEMO_LOG_LEVEL')
  ]);

  WriteLn('Environment: ', AEnvironment);
  WriteLn('  Application: ', Env.GetRequired('DEMO_APP_NAME'));
  WriteLn('  Port: ', Env.GetIntRequired('DEMO_PORT'));
  WriteLn('  Debug: ', Env.GetBoolRequired('DEMO_DEBUG'));
  WriteLn('  Log level: ', Env.GetRequired('DEMO_LOG_LEVEL'));
  WriteLn('  Files:');
  Files := Env.LoadedFiles;
  for I := 0 to High(Files) do
    WriteLn('    - ', ExtractFileName(Files[I]));
  WriteLn;
end;

var
  DemoDir, OriginalDir, DetectedEnvironment: string;
  Env: TDotEnv;
  Options: TDotEnvOptions;

begin
  Randomize;
  OriginalDir := GetCurrentDir;
  DemoDir := CreateDemoDirectory;
  try
    try
      if not SetCurrentDir(DemoDir) then
        raise Exception.CreateFmt(
          'Unable to enter demo directory: %s', [DemoDir]);
      CreateDemoFiles;

      WriteLn('=== dotenv-fp Environment-aware Loading ===');
      WriteLn;
      DemonstrateEnvironment('development');
      DemonstrateEnvironment('production');

      DetectedEnvironment := GetEnvironmentVariable('APP_ENV');
      if DetectedEnvironment = '' then
        DetectedEnvironment := GetEnvironmentVariable('NODE_ENV');
      if DetectedEnvironment = '' then
        DetectedEnvironment := '(none; base file only)';

      Options := TDotEnvOptions.Default;
      Options.Override := True;
      Env := TDotEnv.CreateWithOptions(Options);
      Env.LoadForEnvironment;
      WriteLn('Auto-detected environment: ', DetectedEnvironment);
      WriteLn('Auto-detected load count: ', Env.Count);
    except
      on E: Exception do
      begin
        WriteLn(StdErr, 'Environment example failed: ', E.Message);
        ExitCode := 1;
      end;
    end;
  finally
    SetCurrentDir(OriginalDir);
    RemoveDemoDirectory(DemoDir);
  end;
end.

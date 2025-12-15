program setup_example;

{$mode objfpc}{$H+}{$J-}

(*
  ==========================================================================
  setup_example.pas - Demonstrates v1.1.0 features
  ==========================================================================

  This example demonstrates the new features added in version 1.1.0:

  1. LoadForEnvironment() - Environment-aware loading
  2. Save() - Save configuration to file
  3. GetOrPrompt() - Interactive prompts for missing values
  4. GenerateExample() - Create .env.example files

  Usage:
    1. Run this program
    2. It will prompt you for configuration values
    3. Values are saved to .env
    4. A .env.example file is generated

  ==========================================================================
*)

uses
  DotEnv, SysUtils;

var
  Env: TDotEnv;
  AppName, DbUrl, Port, Debug: string;

begin
  WriteLn('===========================================');
  WriteLn('  dotenv-fp v1.1.0 - Setup Example');
  WriteLn('===========================================');
  WriteLn;

  // Create dotenv instance
  Env := TDotEnv.Create;

  // Try to load existing .env file
  WriteLn('Checking for existing .env file...');
  if Env.Load('.env') then
    WriteLn('Found existing .env file. Loaded ', Env.Count, ' variables.')
  else
    WriteLn('No .env file found. Starting fresh setup.');
  WriteLn;

  // Use GetOrPrompt() to interactively configure the application
  WriteLn('=== Application Configuration ===');
  WriteLn;

  AppName := Env.GetOrPrompt('APP_NAME',
                             'Enter application name',
                             'MyPascalApp');

  DbUrl := Env.GetOrPrompt('DATABASE_URL',
                          'Enter database URL',
                          'postgres://localhost/mydb');

  Port := Env.GetOrPrompt('PORT',
                         'Enter application port',
                         '3000');

  Debug := Env.GetOrPrompt('DEBUG',
                          'Enable debug mode? (true/false)',
                          'false');

  WriteLn;
  WriteLn('===========================================');
  WriteLn('  Configuration Summary');
  WriteLn('===========================================');
  WriteLn('APP_NAME     : ', AppName);
  WriteLn('DATABASE_URL : ', DbUrl);
  WriteLn('PORT         : ', Port);
  WriteLn('DEBUG        : ', Debug);
  WriteLn;

  // Save the configuration to .env
  WriteLn('Saving configuration to .env...');
  if Env.Save('.env') then
    WriteLn('✓ Configuration saved successfully!')
  else
    WriteLn('✗ Error saving configuration!');

  // Generate .env.example for version control
  WriteLn('Generating .env.example...');
  if Env.GenerateExample('.env', '.env.example') then
    WriteLn('✓ Example file created successfully!')
  else
    WriteLn('✗ Error creating example file!');

  WriteLn;
  WriteLn('===========================================');
  WriteLn('Setup complete!');
  WriteLn;
  WriteLn('Files created:');
  WriteLn('  - .env          (your configuration - DO NOT commit!)');
  WriteLn('  - .env.example  (template - commit to Git)');
  WriteLn('===========================================');
end.

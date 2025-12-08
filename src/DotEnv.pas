{
  DotEnv.pas - A dotenv library for Free Pascal 3.2.2
  
  Features:
  - Load environment variables from .env files
  - Variable interpolation (${VAR} and $VAR syntax)
  - Multi-line values support
  - Quoted values (single, double, unquoted)
  - Export prefix support
  - Comments support
  - Type-safe getters with defaults
  - Required variable validation
  - Multiple file loading
  - Environment prefixing
  
  Usage:
    uses DotEnv;
    
    var
      Env: TDotEnv;
    begin
      Env := TDotEnv.Create;
      Env.Load;  // Loads .env from current directory
      WriteLn(Env.Get('DATABASE_URL'));
      WriteLn(Env.GetInt('PORT', 3000));
    end;
}
unit DotEnv;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  Classes, SysUtils, StrUtils;

type
  { TDotEnvPair - Key-value pair for environment variables }
  TDotEnvPair = record
    Key: string;
    Value: string;
  end;
  
  TDotEnvPairArray = array of TDotEnvPair;
  TStringArray = array of string;

  { TDotEnvOptions - Configuration options for loading }
  TDotEnvOptions = record
    Override: Boolean;        // Override existing environment variables
    Interpolate: Boolean;     // Enable variable interpolation
    Encoding: string;         // File encoding (default: UTF-8)
    Verbose: Boolean;         // Print debug information
    Prefix: string;           // Prefix to add to all loaded variables
    
    class function Default: TDotEnvOptions; static;
  end;

  { TDotEnvValues - Internal storage for parsed values }
  TDotEnvValues = record
  private
    FItems: TDotEnvPairArray;
    FCount: Integer;
    procedure Grow;
  public
    procedure Init;
    procedure Add(const AKey, AValue: string);
    function Find(const AKey: string): Integer;
    function Get(const AKey: string; const ADefault: string = ''): string;
    procedure Clear;
    function Count: Integer;
    function GetPair(AIndex: Integer): TDotEnvPair;
  end;

  { TDotEnv - Main dotenv record }
  TDotEnv = record
  private
    FValues: TDotEnvValues;
    FOptions: TDotEnvOptions;
    FLoaded: Boolean;
    FLoadedFiles: TStringArray;
    
    function ParseLine(const ALine: string; out AKey, AValue: string): Boolean;
    function ParseValue(const ARawValue: string; AQuoteChar: Char): string;
    function InterpolateValue(const AValue: string): string;
    function ExpandVariable(const AVarName: string): string;
    procedure ApplyToEnvironment(const AKey, AValue: string);
    function ParseMultiLine(const ALines: TStringList; var AIndex: Integer; 
      const AStartValue: string; AQuoteChar: Char): string;
    function DetectQuote(const AValue: string; out AQuoteChar: Char): string;
  public
    { Initialization }
    class function Create: TDotEnv; static;
    class function CreateWithOptions(const AOptions: TDotEnvOptions): TDotEnv; static;
    
    { Loading }
    function Load(const APath: string = '.env'): Boolean;
    function LoadFromStream(AStream: TStream): Boolean;
    function LoadFromString(const AContent: string): Boolean;
    function LoadMultiple(const APaths: array of string): Boolean;
    
    { Getters - String }
    function Get(const AKey: string; const ADefault: string = ''): string;
    function GetRequired(const AKey: string): string;
    
    { Getters - Integer }
    function GetInt(const AKey: string; const ADefault: Integer = 0): Integer;
    function GetIntRequired(const AKey: string): Integer;
    
    { Getters - Boolean }
    function GetBool(const AKey: string; const ADefault: Boolean = False): Boolean;
    function GetBoolRequired(const AKey: string): Boolean;
    
    { Getters - Float }
    function GetFloat(const AKey: string; const ADefault: Double = 0.0): Double;
    function GetFloatRequired(const AKey: string): Double;
    
    { Getters - Array (comma-separated) }
    function GetArray(const AKey: string; const ASeparator: string = ','): TStringArray;
    
    { Utilities }
    function Has(const AKey: string): Boolean;
    function Keys: TStringArray;
    function Values: TStringArray;
    function AsArray: TDotEnvPairArray;
    function Count: Integer;
    
    { Validation }
    function Validate(const ARequiredKeys: array of string): Boolean;
    function GetMissing(const ARequiredKeys: array of string): TStringArray;
    
    { Environment interaction }
    procedure SetToEnv(const AKey, AValue: string);
    function GetFromEnv(const AKey: string; const ADefault: string = ''): string;
    
    { Debug }
    function ToString: string;
    function LoadedFiles: TStringArray;
    
    { Properties }
    property Options: TDotEnvOptions read FOptions write FOptions;
    property Loaded: Boolean read FLoaded;
  end;

  { EDotEnvException - Exception class for dotenv errors }
  EDotEnvException = class(Exception);
  EDotEnvMissingKey = class(EDotEnvException);
  EDotEnvParseError = class(EDotEnvException);
  EDotEnvFileNotFound = class(EDotEnvException);

{ Global helper functions }
function DotEnvLoad(const APath: string = '.env'): TDotEnv;
function DotEnvGet(const AKey: string; const ADefault: string = ''): string;
procedure DotEnvSet(const AKey, AValue: string);

implementation

var
  GlobalDotEnv: TDotEnv;
  GlobalDotEnvInitialized: Boolean = False;

{ TDotEnvOptions }

class function TDotEnvOptions.Default: TDotEnvOptions;
begin
  Result.Override := False;
  Result.Interpolate := True;
  Result.Encoding := 'UTF-8';
  Result.Verbose := False;
  Result.Prefix := '';
end;

{ TDotEnvValues }

procedure TDotEnvValues.Init;
begin
  SetLength(FItems, 0);
  FCount := 0;
end;

procedure TDotEnvValues.Grow;
var
  NewCapacity: Integer;
begin
  if Length(FItems) = 0 then
    NewCapacity := 16
  else
    NewCapacity := Length(FItems) * 2;
  SetLength(FItems, NewCapacity);
end;

procedure TDotEnvValues.Add(const AKey, AValue: string);
var
  Idx: Integer;
begin
  Idx := Find(AKey);
  if Idx >= 0 then
  begin
    FItems[Idx].Value := AValue;
    Exit;
  end;
  
  if FCount >= Length(FItems) then
    Grow;
    
  FItems[FCount].Key := AKey;
  FItems[FCount].Value := AValue;
  Inc(FCount);
end;

function TDotEnvValues.Find(const AKey: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FCount - 1 do
  begin
    if FItems[I].Key = AKey then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

function TDotEnvValues.Get(const AKey: string; const ADefault: string): string;
var
  Idx: Integer;
begin
  Idx := Find(AKey);
  if Idx >= 0 then
    Result := FItems[Idx].Value
  else
    Result := ADefault;
end;

procedure TDotEnvValues.Clear;
begin
  SetLength(FItems, 0);
  FCount := 0;
end;

function TDotEnvValues.Count: Integer;
begin
  Result := FCount;
end;

function TDotEnvValues.GetPair(AIndex: Integer): TDotEnvPair;
begin
  if (AIndex >= 0) and (AIndex < FCount) then
    Result := FItems[AIndex]
  else
  begin
    Result.Key := '';
    Result.Value := '';
  end;
end;

{ TDotEnv }

class function TDotEnv.Create: TDotEnv;
begin
  Result.FValues.Init;
  Result.FOptions := TDotEnvOptions.Default;
  Result.FLoaded := False;
  SetLength(Result.FLoadedFiles, 0);
end;

class function TDotEnv.CreateWithOptions(const AOptions: TDotEnvOptions): TDotEnv;
begin
  Result := TDotEnv.Create;
  Result.FOptions := AOptions;
end;

function TDotEnv.DetectQuote(const AValue: string; out AQuoteChar: Char): string;
var
  Trimmed: string;
begin
  Trimmed := TrimLeft(AValue);
  AQuoteChar := #0;
  
  if Length(Trimmed) = 0 then
  begin
    Result := '';
    Exit;
  end;
  
  if (Trimmed[1] = '"') or (Trimmed[1] = '''') then
  begin
    AQuoteChar := Trimmed[1];
    Result := Copy(Trimmed, 2, Length(Trimmed) - 1);
  end
  else
    Result := Trimmed;
end;

function TDotEnv.ParseValue(const ARawValue: string; AQuoteChar: Char): string;
var
  I: Integer;
  InEscape: Boolean;
  Ch: Char;
begin
  Result := '';
  
  if AQuoteChar = #0 then
  begin
    // Unquoted: strip inline comments
    I := Pos('#', ARawValue);
    if I > 0 then
      Result := TrimRight(Copy(ARawValue, 1, I - 1))
    else
      Result := TrimRight(ARawValue);
    Exit;
  end;
  
  // Handle quoted values
  InEscape := False;
  for I := 1 to Length(ARawValue) do
  begin
    Ch := ARawValue[I];
    
    if InEscape then
    begin
      case Ch of
        'n': Result := Result + #10;
        'r': Result := Result + #13;
        't': Result := Result + #9;
        '\': Result := Result + '\';
        '"': Result := Result + '"';
        '''': Result := Result + '''';
      else
        Result := Result + '\' + Ch;
      end;
      InEscape := False;
    end
    else if (Ch = '\') and (AQuoteChar = '"') then
      InEscape := True
    else if Ch = AQuoteChar then
      Break  // End of quoted value
    else
      Result := Result + Ch;
  end;
end;

function TDotEnv.ParseMultiLine(const ALines: TStringList; var AIndex: Integer;
  const AStartValue: string; AQuoteChar: Char): string;
var
  Line: string;
  EndPos: Integer;
begin
  Result := AStartValue;
  
  while AIndex < ALines.Count - 1 do
  begin
    Inc(AIndex);
    Line := ALines[AIndex];
    
    // Look for closing quote
    EndPos := Pos(AQuoteChar, Line);
    if EndPos > 0 then
    begin
      Result := Result + #10 + Copy(Line, 1, EndPos - 1);
      Exit;
    end
    else
      Result := Result + #10 + Line;
  end;
end;

function TDotEnv.ExpandVariable(const AVarName: string): string;
var
  Idx: Integer;
begin
  // First check our loaded values
  Idx := FValues.Find(AVarName);
  if Idx >= 0 then
    Result := FValues.GetPair(Idx).Value
  else
    // Then check system environment
    Result := SysUtils.GetEnvironmentVariable(AVarName);
end;

function TDotEnv.InterpolateValue(const AValue: string): string;
var
  I, J, VarStart: Integer;
  VarName: string;
  InBrace: Boolean;
  Ch: Char;
begin
  if not FOptions.Interpolate then
  begin
    Result := AValue;
    Exit;
  end;
  
  Result := '';
  I := 1;
  
  while I <= Length(AValue) do
  begin
    Ch := AValue[I];
    
    if Ch = '$' then
    begin
      if (I < Length(AValue)) and (AValue[I + 1] = '{') then
      begin
        // ${VAR} syntax
        InBrace := True;
        VarStart := I + 2;
        J := VarStart;
        while (J <= Length(AValue)) and (AValue[J] <> '}') do
          Inc(J);
          
        if J <= Length(AValue) then
        begin
          VarName := Copy(AValue, VarStart, J - VarStart);
          Result := Result + ExpandVariable(VarName);
          I := J + 1;
          Continue;
        end;
      end
      else if I < Length(AValue) then
      begin
        // $VAR syntax
        VarStart := I + 1;
        J := VarStart;
        while (J <= Length(AValue)) and 
              (AValue[J] in ['A'..'Z', 'a'..'z', '0'..'9', '_']) do
          Inc(J);
          
        if J > VarStart then
        begin
          VarName := Copy(AValue, VarStart, J - VarStart);
          Result := Result + ExpandVariable(VarName);
          I := J;
          Continue;
        end;
      end;
    end;
    
    Result := Result + Ch;
    Inc(I);
  end;
end;

function TDotEnv.ParseLine(const ALine: string; out AKey, AValue: string): Boolean;
var
  Line, TrimmedLine: string;
  EqPos: Integer;
  RawValue: string;
  QuoteChar: Char;
begin
  Result := False;
  AKey := '';
  AValue := '';
  
  Line := ALine;
  TrimmedLine := Trim(Line);
  
  // Skip empty lines and comments
  if (TrimmedLine = '') or (TrimmedLine[1] = '#') then
    Exit;
  
  // Handle 'export' prefix
  if AnsiStartsStr('export ', TrimmedLine) then
    TrimmedLine := Trim(Copy(TrimmedLine, 8, Length(TrimmedLine)));
  
  // Find '=' sign
  EqPos := Pos('=', TrimmedLine);
  if EqPos = 0 then
    Exit;
  
  AKey := Trim(Copy(TrimmedLine, 1, EqPos - 1));
  if AKey = '' then
    Exit;
  
  // Apply prefix if set
  if FOptions.Prefix <> '' then
    AKey := FOptions.Prefix + AKey;
  
  RawValue := Copy(TrimmedLine, EqPos + 1, Length(TrimmedLine));
  RawValue := DetectQuote(RawValue, QuoteChar);
  AValue := ParseValue(RawValue, QuoteChar);
  
  Result := True;
end;

procedure TDotEnv.ApplyToEnvironment(const AKey, AValue: string);
var
  CurrentValue: string;
begin
  CurrentValue := SysUtils.GetEnvironmentVariable(AKey);
  
  if (CurrentValue = '') or FOptions.Override then
  begin
    {$IFDEF WINDOWS}
    // On Windows, we can use SetEnvironmentVariable
    // For cross-platform, we just store internally
    {$ENDIF}
    // Store in our internal storage regardless
  end;
end;

function TDotEnv.Load(const APath: string): Boolean;
var
  Lines: TStringList;
  I: Integer;
  Key, Value, RawValue, TrimmedLine: string;
  QuoteChar: Char;
  EqPos: Integer;
  FullPath: string;
begin
  Result := False;
  
  if APath = '' then
    FullPath := '.env'
  else
    FullPath := APath;
  
  if not FileExists(FullPath) then
  begin
    if FOptions.Verbose then
      WriteLn('DotEnv: File not found: ', FullPath);
    Exit;
  end;
  
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(FullPath);
    
    I := 0;
    while I < Lines.Count do
    begin
      TrimmedLine := Trim(Lines[I]);
      
      // Skip empty lines and comments
      if (TrimmedLine = '') or (TrimmedLine[1] = '#') then
      begin
        Inc(I);
        Continue;
      end;
      
      // Handle 'export' prefix
      if AnsiStartsStr('export ', TrimmedLine) then
        TrimmedLine := Trim(Copy(TrimmedLine, 8, Length(TrimmedLine)));
      
      // Find '=' sign
      EqPos := Pos('=', TrimmedLine);
      if EqPos = 0 then
      begin
        Inc(I);
        Continue;
      end;
      
      Key := Trim(Copy(TrimmedLine, 1, EqPos - 1));
      if Key = '' then
      begin
        Inc(I);
        Continue;
      end;
      
      // Apply prefix if set
      if FOptions.Prefix <> '' then
        Key := FOptions.Prefix + Key;
      
      RawValue := Copy(TrimmedLine, EqPos + 1, Length(TrimmedLine));
      RawValue := DetectQuote(RawValue, QuoteChar);
      
      // Check for multi-line
      if (QuoteChar <> #0) and (Pos(QuoteChar, RawValue) = 0) then
        Value := ParseMultiLine(Lines, I, ParseValue(RawValue, #0), QuoteChar)
      else
        Value := ParseValue(RawValue, QuoteChar);
      
      // Interpolate
      Value := InterpolateValue(Value);
      
      // Check if we should override
      if not FOptions.Override then
      begin
        if SysUtils.GetEnvironmentVariable(Key) <> '' then
        begin
          Inc(I);
          Continue;
        end;
      end;
      
      FValues.Add(Key, Value);
      
      if FOptions.Verbose then
        WriteLn('DotEnv: Loaded ', Key, '=', Value);
      
      Inc(I);
    end;
    
    // Track loaded files
    SetLength(FLoadedFiles, Length(FLoadedFiles) + 1);
    FLoadedFiles[High(FLoadedFiles)] := FullPath;
    
    FLoaded := True;
    Result := True;
  finally
    Lines.Free;
  end;
end;

function TDotEnv.LoadFromStream(AStream: TStream): Boolean;
var
  Lines: TStringList;
  Content: string;
begin
  Lines := TStringList.Create;
  try
    Lines.LoadFromStream(AStream);
    Content := Lines.Text;
  finally
    Lines.Free;
  end;
  
  Result := LoadFromString(Content);
end;

function TDotEnv.LoadFromString(const AContent: string): Boolean;
var
  Lines: TStringList;
  I: Integer;
  Key, Value, RawValue, TrimmedLine: string;
  QuoteChar: Char;
  EqPos: Integer;
begin
  Result := False;
  
  Lines := TStringList.Create;
  try
    Lines.Text := AContent;
    
    I := 0;
    while I < Lines.Count do
    begin
      TrimmedLine := Trim(Lines[I]);
      
      // Skip empty lines and comments
      if (TrimmedLine = '') or (TrimmedLine[1] = '#') then
      begin
        Inc(I);
        Continue;
      end;
      
      // Handle 'export' prefix
      if AnsiStartsStr('export ', TrimmedLine) then
        TrimmedLine := Trim(Copy(TrimmedLine, 8, Length(TrimmedLine)));
      
      // Find '=' sign
      EqPos := Pos('=', TrimmedLine);
      if EqPos = 0 then
      begin
        Inc(I);
        Continue;
      end;
      
      Key := Trim(Copy(TrimmedLine, 1, EqPos - 1));
      if Key = '' then
      begin
        Inc(I);
        Continue;
      end;
      
      // Apply prefix if set
      if FOptions.Prefix <> '' then
        Key := FOptions.Prefix + Key;
      
      RawValue := Copy(TrimmedLine, EqPos + 1, Length(TrimmedLine));
      RawValue := DetectQuote(RawValue, QuoteChar);
      
      // Check for multi-line
      if (QuoteChar <> #0) and (Pos(QuoteChar, RawValue) = 0) then
        Value := ParseMultiLine(Lines, I, ParseValue(RawValue, #0), QuoteChar)
      else
        Value := ParseValue(RawValue, QuoteChar);
      
      // Interpolate
      Value := InterpolateValue(Value);
      
      FValues.Add(Key, Value);
      Inc(I);
    end;
    
    FLoaded := True;
    Result := True;
  finally
    Lines.Free;
  end;
end;

function TDotEnv.LoadMultiple(const APaths: array of string): Boolean;
var
  I: Integer;
  AnyLoaded: Boolean;
begin
  AnyLoaded := False;
  for I := Low(APaths) to High(APaths) do
  begin
    if Load(APaths[I]) then
      AnyLoaded := True;
  end;
  Result := AnyLoaded;
end;

function TDotEnv.Get(const AKey: string; const ADefault: string): string;
var
  Idx: Integer;
begin
  Idx := FValues.Find(AKey);
  if Idx >= 0 then
    Result := FValues.GetPair(Idx).Value
  else
  begin
    // Fall back to system environment
    Result := SysUtils.GetEnvironmentVariable(AKey);
    if Result = '' then
      Result := ADefault;
  end;
end;

function TDotEnv.GetRequired(const AKey: string): string;
begin
  Result := Get(AKey, '');
  if Result = '' then
    raise EDotEnvMissingKey.CreateFmt('Required environment variable not found: %s', [AKey]);
end;

function TDotEnv.GetInt(const AKey: string; const ADefault: Integer): Integer;
var
  S: string;
begin
  S := Get(AKey, '');
  if S = '' then
    Result := ADefault
  else
  begin
    if not TryStrToInt(S, Result) then
      Result := ADefault;
  end;
end;

function TDotEnv.GetIntRequired(const AKey: string): Integer;
var
  S: string;
begin
  S := GetRequired(AKey);
  if not TryStrToInt(S, Result) then
    raise EDotEnvParseError.CreateFmt('Cannot convert %s to integer: %s', [AKey, S]);
end;

function TDotEnv.GetBool(const AKey: string; const ADefault: Boolean): Boolean;
var
  S: string;
begin
  S := LowerCase(Trim(Get(AKey, '')));
  if S = '' then
    Result := ADefault
  else
    Result := (S = 'true') or (S = '1') or (S = 'yes') or (S = 'on');
end;

function TDotEnv.GetBoolRequired(const AKey: string): Boolean;
var
  S: string;
begin
  S := LowerCase(Trim(GetRequired(AKey)));
  Result := (S = 'true') or (S = '1') or (S = 'yes') or (S = 'on');
end;

function TDotEnv.GetFloat(const AKey: string; const ADefault: Double): Double;
var
  S: string;
begin
  S := Get(AKey, '');
  if S = '' then
    Result := ADefault
  else
  begin
    if not TryStrToFloat(S, Result) then
      Result := ADefault;
  end;
end;

function TDotEnv.GetFloatRequired(const AKey: string): Double;
var
  S: string;
begin
  S := GetRequired(AKey);
  if not TryStrToFloat(S, Result) then
    raise EDotEnvParseError.CreateFmt('Cannot convert %s to float: %s', [AKey, S]);
end;

function TDotEnv.GetArray(const AKey: string; const ASeparator: string): TStringArray;
var
  S: string;
  Parts: TStringList;
  I: Integer;
begin
  S := Get(AKey, '');
  if S = '' then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  
  Parts := TStringList.Create;
  try
    Parts.Delimiter := ASeparator[1];
    Parts.StrictDelimiter := True;
    Parts.DelimitedText := S;
    
    SetLength(Result, Parts.Count);
    for I := 0 to Parts.Count - 1 do
      Result[I] := Trim(Parts[I]);
  finally
    Parts.Free;
  end;
end;

function TDotEnv.Has(const AKey: string): Boolean;
begin
  Result := (FValues.Find(AKey) >= 0) or 
            (SysUtils.GetEnvironmentVariable(AKey) <> '');
end;

function TDotEnv.Keys: TStringArray;
var
  I: Integer;
begin
  SetLength(Result, FValues.Count);
  for I := 0 to FValues.Count - 1 do
    Result[I] := FValues.GetPair(I).Key;
end;

function TDotEnv.Values: TStringArray;
var
  I: Integer;
begin
  SetLength(Result, FValues.Count);
  for I := 0 to FValues.Count - 1 do
    Result[I] := FValues.GetPair(I).Value;
end;

function TDotEnv.AsArray: TDotEnvPairArray;
var
  I: Integer;
begin
  SetLength(Result, FValues.Count);
  for I := 0 to FValues.Count - 1 do
    Result[I] := FValues.GetPair(I);
end;

function TDotEnv.Count: Integer;
begin
  Result := FValues.Count;
end;

function TDotEnv.Validate(const ARequiredKeys: array of string): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := Low(ARequiredKeys) to High(ARequiredKeys) do
  begin
    if not Has(ARequiredKeys[I]) then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

function TDotEnv.GetMissing(const ARequiredKeys: array of string): TStringArray;
var
  I, MissingCount: Integer;
  Temp: TStringArray;
begin
  SetLength(Temp, Length(ARequiredKeys));
  MissingCount := 0;
  
  for I := Low(ARequiredKeys) to High(ARequiredKeys) do
  begin
    if not Has(ARequiredKeys[I]) then
    begin
      Temp[MissingCount] := ARequiredKeys[I];
      Inc(MissingCount);
    end;
  end;
  
  SetLength(Result, MissingCount);
  for I := 0 to MissingCount - 1 do
    Result[I] := Temp[I];
end;

procedure TDotEnv.SetToEnv(const AKey, AValue: string);
begin
  FValues.Add(AKey, AValue);
end;

function TDotEnv.GetFromEnv(const AKey: string; const ADefault: string): string;
begin
  Result := SysUtils.GetEnvironmentVariable(AKey);
  if Result = '' then
    Result := ADefault;
end;

function TDotEnv.ToString: string;
var
  I: Integer;
  Pair: TDotEnvPair;
begin
  Result := '';
  for I := 0 to FValues.Count - 1 do
  begin
    Pair := FValues.GetPair(I);
    if Result <> '' then
      Result := Result + LineEnding;
    Result := Result + Pair.Key + '=' + Pair.Value;
  end;
end;

function TDotEnv.LoadedFiles: TStringArray;
begin
  Result := FLoadedFiles;
end;

{ Global helper functions }

function DotEnvLoad(const APath: string): TDotEnv;
begin
  if not GlobalDotEnvInitialized then
  begin
    GlobalDotEnv := TDotEnv.Create;
    GlobalDotEnvInitialized := True;
  end;
  GlobalDotEnv.Load(APath);
  Result := GlobalDotEnv;
end;

function DotEnvGet(const AKey: string; const ADefault: string): string;
begin
  if not GlobalDotEnvInitialized then
  begin
    GlobalDotEnv := TDotEnv.Create;
    GlobalDotEnv.Load;
    GlobalDotEnvInitialized := True;
  end;
  Result := GlobalDotEnv.Get(AKey, ADefault);
end;

procedure DotEnvSet(const AKey, AValue: string);
begin
  if not GlobalDotEnvInitialized then
  begin
    GlobalDotEnv := TDotEnv.Create;
    GlobalDotEnvInitialized := True;
  end;
  GlobalDotEnv.SetToEnv(AKey, AValue);
end;

end.

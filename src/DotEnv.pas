(*
  ==========================================================================
  DotEnv.pas - A dotenv library for Free Pascal 3.2.2+
  ==========================================================================
  
  This unit provides functionality to load environment variables from .env
  files, similar to the popular python-dotenv library. It's designed to help
  manage application configuration without hardcoding sensitive data.
  
  FEATURES:
  --------------------------------------------------------------------------
  - Load environment variables from .env files
  - Variable interpolation (${VAR} and $VAR syntax)
  - Multi-line values support (using quotes)
  - Quoted values (single quotes, double quotes, or unquoted)
  - Export prefix support (for shell compatibility)
  - Comments support (# for line and inline comments)
  - Type-safe getters with defaults (GetInt, GetBool, GetFloat, GetArray)
  - Required variable validation with custom exceptions
  - Multiple file loading (.env, .env.local, .env.production, etc.)
  - Key prefixing (add APP_ prefix to all loaded keys)
  - Zero memory leaks using advanced records
  
  BASIC USAGE:
  --------------------------------------------------------------------------
    uses DotEnv;
    
    var
      Env: TDotEnv;
    begin
      Env := TDotEnv.Create;
      Env.Load;  // Loads .env from current directory
      WriteLn(Env.Get('DATABASE_URL'));
      WriteLn(Env.GetInt('PORT', 3000));
      WriteLn(Env.GetBool('DEBUG', False));
    end;
  
  ADVANCED USAGE WITH OPTIONS:
  --------------------------------------------------------------------------
    var
      Env: TDotEnv;
      Options: TDotEnvOptions;
    begin
      Options := TDotEnvOptions.Default;
      Options.Override := True;    // Override existing env vars
      Options.Prefix := 'APP_';    // Add prefix to all keys
      
      Env := TDotEnv.CreateWithOptions(Options);
      Env.LoadMultiple(['.env', '.env.local']);
    end;
  
  ARCHITECTURE NOTES:
  --------------------------------------------------------------------------
  This library uses Free Pascal's "advanced records" feature, which allows
  records to have methods, constructors, and properties similar to classes.
  The key advantage is automatic memory management - no need to call Free!
  
  The main components are:
  - TDotEnvOptions: Configuration record for customizing load behavior
  - TDotEnvValues: Internal storage for parsed key-value pairs
  - TDotEnv: Main record that users interact with
  - EDotEnvException: Base exception class with specialized subclasses
  
  LICENSE: MIT
  AUTHOR: ikelaiah
  VERSION: 1.0.0
  ==========================================================================
*)
unit DotEnv;

(* Compiler directives:
   - objfpc: Use Object Free Pascal dialect (modern OOP features)
   - H+: Use AnsiString as default string type (long strings)
   - advancedrecords: Enable methods and properties in records *)
{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  Classes,   // TStringList, TStream - for file and string handling
  SysUtils,  // File operations, string conversions, exceptions
  StrUtils,  // AnsiStartsStr - for string prefix checking
  Types;     // TStringDynArray - dynamic array of strings

type
  (*
    TDotEnvPair - Key-value pair for environment variables
    --------------------------------------------------------------------------
    A simple record to store a single environment variable with its key and
    value. Used internally by TDotEnvValues and returned by AsArray method.
    
    Example:
      var Pair: TDotEnvPair;
      Pair.Key := 'DATABASE_URL';
      Pair.Value := 'postgresql://localhost/mydb';
  *)
  TDotEnvPair = record
    Key: string;    // The variable name, e.g., 'DATABASE_URL'
    Value: string;  // The variable value, e.g., 'postgresql://localhost/mydb'
  end;
  
  // Dynamic array of TDotEnvPair - used for bulk operations
  TDotEnvPairArray = array of TDotEnvPair;

  (*
    TDotEnvOptions - Configuration options for loading .env files
    --------------------------------------------------------------------------
    This record holds all configuration options that control how .env files
    are parsed and how values are processed. Use TDotEnvOptions.Default to
    get sensible defaults, then customize as needed.
    
    Example:
      var Options: TDotEnvOptions;
      Options := TDotEnvOptions.Default;
      Options.Override := True;     // Override system env vars
      Options.Prefix := 'MYAPP_';   // Add prefix to all keys
  *)
  TDotEnvOptions = record
    (* When True, values from .env override existing system environment
       variables. When False (default), existing system vars are preserved.
       Use True for development, False for production. *)
    Override: Boolean;
    
    (* When True (default), enables ${VAR} and $VAR variable interpolation.
       Variables are resolved from: 1) previously loaded values, 2) system env.
       Set to False if you need literal ${} in your values. *)
    Interpolate: Boolean;
    
    (* File encoding for reading .env files. Default is 'UTF-8'.
       Currently informational - TStringList handles encoding automatically. *)
    Encoding: string;
    
    (* When True, prints debug information during loading.
       Useful for troubleshooting which values are being loaded.
       Example output: "DotEnv: Loaded DATABASE_URL=postgres://..." *)
    Verbose: Boolean;
    
    (* Prefix to add to all loaded variable names.
       Example: If Prefix='APP_' and .env has KEY=value,
       it becomes accessible as 'APP_KEY'.
       Useful for namespacing when loading multiple .env files. *)
    Prefix: string;
    
    (* Returns a TDotEnvOptions record with sensible default values:
       - Override: False (don't override system env vars)
       - Interpolate: True (enable ${VAR} syntax)
       - Encoding: 'UTF-8'
       - Verbose: False (quiet mode)
       - Prefix: '' (no prefix) *)
    class function Default: TDotEnvOptions; static;
  end;

  (*
    TDotEnvValues - Internal storage for parsed key-value pairs
    --------------------------------------------------------------------------
    This is an internal data structure that stores all loaded environment
    variables. It uses a dynamic array with manual growth management for
    efficiency. Users typically don't interact with this directly.
    
    IMPLEMENTATION NOTES:
    - Uses a simple linear search for Find() - adequate for typical .env sizes
    - Array grows by doubling capacity when full (amortized O(1) insertion)
    - Add() updates existing keys instead of creating duplicates
  *)
  TDotEnvValues = record
  private
    FItems: TDotEnvPairArray;  // Storage array for key-value pairs
    FCount: Integer;           // Number of items currently stored
    
    (* Doubles the capacity of FItems array when more space is needed.
       Initial capacity is 16, then grows to 32, 64, 128, etc. *)
    procedure Grow;
  public
    (* Initializes the record - MUST be called before first use.
       Sets FItems to empty array and FCount to 0. *)
    procedure Init;
    
    (* Adds or updates a key-value pair.
       If key exists, updates the value. Otherwise, adds new pair. *)
    procedure Add(const AKey, AValue: string);
    
    (* Searches for a key and returns its index, or -1 if not found.
       Uses linear search - O(n) complexity. *)
    function Find(const AKey: string): Integer;
    
    // Gets a value by key, returning ADefault if not found.
    function Get(const AKey: string; const ADefault: string = ''): string;
    
    // Removes all stored key-value pairs.
    procedure Clear;
    
    // Returns the number of stored key-value pairs.
    function Count: Integer;
    
    (* Returns the key-value pair at the specified index.
       Returns empty pair if index is out of bounds. *)
    function GetPair(AIndex: Integer): TDotEnvPair;
  end;

  (*
    TDotEnv - Main dotenv record for loading and accessing environment variables
    --------------------------------------------------------------------------
    This is the primary type that users interact with. It handles:
    - Loading .env files from disk or strings
    - Parsing various value formats (quoted, unquoted, multi-line)
    - Variable interpolation (${VAR} and $VAR syntax)
    - Type-safe value retrieval with defaults
    - Validation of required variables
    
    IMPORTANT: This is an "advanced record" - it has methods like a class
    but doesn't require manual memory management (no Free needed!).
    
    BASIC EXAMPLE:
      var Env: TDotEnv;
      Env := TDotEnv.Create;
      Env.Load;  // Loads .env from current directory
      WriteLn(Env.Get('DATABASE_URL'));
  *)
  TDotEnv = record
  private
    FValues: TDotEnvValues;      // Internal storage for loaded key-value pairs
    FOptions: TDotEnvOptions;    // Configuration options for loading/parsing
    FLoaded: Boolean;            // True if at least one file was loaded successfully
    FLoadedFiles: TStringDynArray;  // List of files that were successfully loaded
    
    (* -----------------------------------------------------------------------
       PRIVATE PARSING METHODS
       These methods handle the complex task of parsing .env file syntax.
       ----------------------------------------------------------------------- *)
    
    (* Parses a single line from .env file into key and value.
       Handles: comments, export prefix, quoted values.
       Returns True if line contains a valid key=value pair. *)
    function ParseLine(const ALine: string; out AKey, AValue: string): Boolean;
    
    (* Processes a raw value string, handling quotes and escape sequences.
       AQuoteChar: #0 for unquoted, '"' for double-quoted, '''' for single-quoted.
       For double quotes: processes \n, \r, \t, \\, \" escape sequences.
       For single quotes: returns literal value (no escape processing).
       For unquoted: strips inline comments (everything after #). *)
    function ParseValue(const ARawValue: string; AQuoteChar: Char): string;
    
    (* Performs variable interpolation on a value string.
       Replaces ${VAR} and $VAR with their values.
       Resolution order: 1) loaded values, 2) system environment. *)
    function InterpolateValue(const AValue: string): string;
    
    (* Expands a single variable name to its value.
       First checks loaded values, then system environment.
       Returns empty string if variable not found. *)
    function ExpandVariable(const AVarName: string): string;
    
    (* Placeholder for applying values to system environment.
       Currently only stores values internally. *)
    procedure ApplyToEnvironment(const AKey, AValue: string);
    
    (* Handles multi-line values that span multiple lines in the file.
       Called when opening quote is found but closing quote is not on same line.
       Continues reading lines until closing quote is found. *)
    function ParseMultiLine(const ALines: TStringList; var AIndex: Integer; 
      const AStartValue: string; AQuoteChar: Char): string;
    
    (* Detects if a value starts with a quote character.
       Returns the value with opening quote removed.
       Sets AQuoteChar to the quote character, or #0 if unquoted. *)
    function DetectQuote(const AValue: string; out AQuoteChar: Char): string;
  public
    (* =====================================================================
       INITIALIZATION METHODS
       ===================================================================== *)
    
    (* Creates a new TDotEnv instance with default options.
       This is the standard way to create a TDotEnv.
       Example: Env := TDotEnv.Create; *)
    class function Create: TDotEnv; static;
    
    (* Creates a new TDotEnv instance with custom options.
       Use this when you need to customize loading behavior.
       Example:
         Options := TDotEnvOptions.Default;
         Options.Override := True;
         Env := TDotEnv.CreateWithOptions(Options); *)
    class function CreateWithOptions(const AOptions: TDotEnvOptions): TDotEnv; static;
    
    (* =====================================================================
       LOADING METHODS
       ===================================================================== *)
    
    (* Loads environment variables from a file.
       APath: Path to .env file (default: '.env' in current directory)
       Returns: True if file was found and loaded successfully.
       Note: Silently returns False if file doesn't exist (no exception). *)
    function Load(const APath: string = '.env'): Boolean;
    
    (* Loads environment variables from a TStream.
       Useful for loading from resources, network, or memory.
       Returns: True if stream was parsed successfully. *)
    function LoadFromStream(AStream: TStream): Boolean;
    
    (* Loads environment variables from a string.
       Great for testing or loading from non-file sources.
       Example: Env.LoadFromString('KEY=value' + LineEnding + 'OTHER=test'); *)
    function LoadFromString(const AContent: string): Boolean;
    
    (* Loads multiple .env files in sequence.
       Later files override values from earlier files.
       Returns: True if at least one file was loaded.
       Example: Env.LoadMultiple(['.env', '.env.local', '.env.development']); *)
    function LoadMultiple(const APaths: array of string): Boolean;
    
    (* =====================================================================
       STRING GETTERS
       ===================================================================== *)
    
    (* Gets a string value by key.
       Falls back to system environment if not in loaded values.
       Returns ADefault if key not found anywhere.
       Example: DbUrl := Env.Get('DATABASE_URL', 'sqlite://local.db'); *)
    function Get(const AKey: string; const ADefault: string = ''): string;
    
    (* Gets a required string value by key.
       Raises EDotEnvMissingKey if the key doesn't exist.
       Use this for configuration that MUST be present. *)
    function GetRequired(const AKey: string): string;
    
    (* =====================================================================
       INTEGER GETTERS
       ===================================================================== *)
    
    (* Gets an integer value by key.
       Returns ADefault if key not found or value is not a valid integer.
       Example: Port := Env.GetInt('PORT', 3000); *)
    function GetInt(const AKey: string; const ADefault: Integer = 0): Integer;
    
    (* Gets a required integer value by key.
       Raises EDotEnvMissingKey if key doesn't exist.
       Raises EDotEnvParseError if value is not a valid integer. *)
    function GetIntRequired(const AKey: string): Integer;
    
    (* =====================================================================
       BOOLEAN GETTERS
       ===================================================================== *)
    
    (* Gets a boolean value by key.
       Recognizes: 'true', '1', 'yes', 'on' as True (case-insensitive).
       Everything else (including empty) returns ADefault.
       Example: Debug := Env.GetBool('DEBUG', False); *)
    function GetBool(const AKey: string; const ADefault: Boolean = False): Boolean;
    
    (* Gets a required boolean value by key.
       Raises EDotEnvMissingKey if key doesn't exist. *)
    function GetBoolRequired(const AKey: string): Boolean;
    
    (* =====================================================================
       FLOAT GETTERS
       ===================================================================== *)
    
    (* Gets a floating-point value by key.
       Returns ADefault if key not found or value is not a valid number.
       Example: Rate := Env.GetFloat('TAX_RATE', 0.07); *)
    function GetFloat(const AKey: string; const ADefault: Double = 0.0): Double;
    
    (* Gets a required float value by key.
       Raises EDotEnvMissingKey if key doesn't exist.
       Raises EDotEnvParseError if value is not a valid float. *)
    function GetFloatRequired(const AKey: string): Double;
    
    (* =====================================================================
       ARRAY GETTER
       ===================================================================== *)
    
    (* Splits a value by separator into an array of strings.
       Useful for comma-separated lists like ALLOWED_HOSTS=host1,host2,host3.
       Each element is trimmed of whitespace.
       Example:
         Hosts := Env.GetArray('ALLOWED_HOSTS');        // Split by comma
         Tags := Env.GetArray('TAGS', ';');             // Split by semicolon *)
    function GetArray(const AKey: string; const ASeparator: string = ','): TStringDynArray;
    
    (* =====================================================================
       UTILITY METHODS
       ===================================================================== *)
    
    (* Checks if a key exists in loaded values OR system environment.
       Example: if Env.Has('OPTIONAL_FEATURE') then EnableFeature; *)
    function Has(const AKey: string): Boolean;
    
    (* Returns an array of all loaded key names.
       Does NOT include system environment variables. *)
    function Keys: TStringDynArray;
    
    (* Returns an array of all loaded values.
       Order corresponds to Keys array. *)
    function Values: TStringDynArray;
    
    (* Returns all loaded key-value pairs as an array of TDotEnvPair.
       Useful for iterating over all loaded variables. *)
    function AsArray: TDotEnvPairArray;
    
    (* Returns the number of loaded key-value pairs.
       Does NOT count system environment variables. *)
    function Count: Integer;
    
    (* =====================================================================
       VALIDATION METHODS
       ===================================================================== *)
    
    (* Checks if all required keys exist (in loaded values OR system env).
       Returns True if ALL keys are present, False otherwise.
       Example: if not Env.Validate(['DB_URL', 'SECRET']) then Halt(1); *)
    function Validate(const ARequiredKeys: array of string): Boolean;
    
    (* Returns an array of keys that are missing from the required list.
       Useful for telling users exactly what configuration is missing.
       Example:
         Missing := Env.GetMissing(['DB_URL', 'SECRET', 'PORT']);
         for Key in Missing do WriteLn('Missing: ', Key); *)
    function GetMissing(const ARequiredKeys: array of string): TStringDynArray;
    
    (* =====================================================================
       ENVIRONMENT INTERACTION
       ===================================================================== *)
    
    (* Sets a key-value pair in the internal storage.
       Does NOT modify system environment variables.
       Useful for programmatically adding configuration at runtime. *)
    procedure SetToEnv(const AKey, AValue: string);
    
    (* Gets a value directly from system environment (bypasses loaded values).
       Returns ADefault if the system env var is not set. *)
    function GetFromEnv(const AKey: string; const ADefault: string = ''): string;
    
    (* =====================================================================
       DEBUG METHODS
       ===================================================================== *)
    
    (* Returns a string representation of all loaded key-value pairs.
       Format: "KEY1=value1\nKEY2=value2\n..."
       Useful for debugging what was loaded. *)
    function ToString: string;
    
    (* Returns the list of file paths that were successfully loaded.
       Useful for debugging which files contributed to configuration. *)
    function LoadedFiles: TStringDynArray;
    
    (* =====================================================================
       PROPERTIES
       ===================================================================== *)
    
    (* Read/write access to configuration options.
       Can be modified after Create but before Load. *)
    property Options: TDotEnvOptions read FOptions write FOptions;
    
    // True if at least one file was successfully loaded.
    property Loaded: Boolean read FLoaded;
  end;

  (*
    Exception classes for dotenv errors
    --------------------------------------------------------------------------
    These exceptions allow calling code to handle specific error conditions.
    All inherit from EDotEnvException for easy catch-all handling.
    
    Example:
      try
        Secret := Env.GetRequired('SECRET_KEY');
      except
        on E: EDotEnvMissingKey do
          WriteLn('Configuration error: ', E.Message);
      end;
  *)
  
  // Base exception class - catch this to handle any dotenv error
  EDotEnvException = class(Exception);
  
  // Raised when GetRequired/GetIntRequired/etc. can't find a key
  EDotEnvMissingKey = class(EDotEnvException);
  
  // Raised when a value can't be converted to the requested type
  EDotEnvParseError = class(EDotEnvException);
  
  // Reserved for future use - file not found errors
  EDotEnvFileNotFound = class(EDotEnvException);

(*
  Global helper functions for simple/quick usage
  --------------------------------------------------------------------------
  These functions provide a simplified API using a global TDotEnv instance.
  Great for scripts or simple applications where you don't need multiple
  TDotEnv instances or fine-grained control.
  
  Example:
    uses DotEnv;
    begin
      DotEnvLoad;  // Load .env from current directory
      WriteLn(DotEnvGet('DATABASE_URL'));
      WriteLn(DotEnvGet('PORT', '3000'));
    end.
*)

(* Loads a .env file into the global instance. Creates instance if needed.
   Returns the global TDotEnv for optional further operations. *)
function DotEnvLoad(const APath: string = '.env'): TDotEnv;

// Gets a value from the global instance. Auto-loads .env if not yet loaded.
function DotEnvGet(const AKey: string; const ADefault: string = ''): string;

// Sets a value in the global instance. Creates instance if needed.
procedure DotEnvSet(const AKey, AValue: string);

implementation

(* =========================================================================
   IMPLEMENTATION SECTION
   =========================================================================
   This section contains the actual code for all methods declared above.
   Private implementation details are hidden from users of this unit.
   ========================================================================= *)

var
  (* Global TDotEnv instance for the simple helper functions.
     Lazily initialized on first use of DotEnvLoad/DotEnvGet/DotEnvSet. *)
  GlobalDotEnv: TDotEnv;
  
  (* Tracks whether GlobalDotEnv has been initialized.
     Prevents re-initialization on each call. *)
  GlobalDotEnvInitialized: Boolean = False;

(* =========================================================================
   TDotEnvOptions Implementation
   ========================================================================= *)

class function TDotEnvOptions.Default: TDotEnvOptions;
begin
  (* Set sensible defaults that work for most use cases:
     - Don't override system env vars (safer for production)
     - Enable variable interpolation (most users expect this)
     - Use UTF-8 encoding (universal standard)
     - Quiet mode (no debug output)
     - No key prefix (load keys as-is) *)
  Result.Override := False;
  Result.Interpolate := True;
  Result.Encoding := 'UTF-8';
  Result.Verbose := False;
  Result.Prefix := '';
end;

(* =========================================================================
   TDotEnvValues Implementation
   -------------------------------------------------------------------------
   This is an internal data structure - a simple dynamic array-based map.
   It's optimized for small to medium numbers of keys (typical .env files).
   ========================================================================= *)

procedure TDotEnvValues.Init;
begin
  // Start with empty array - will grow on first Add
  SetLength(FItems, 0);
  FCount := 0;
end;

procedure TDotEnvValues.Grow;
var
  NewCapacity: Integer;
begin
  (* Double the capacity each time we run out of space.
     This gives amortized O(1) insertion time.
     Start with 16 slots - enough for most .env files. *)
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
  (* First check if key already exists - update if so.
     This handles the case where later .env files override earlier ones,
     or where the same key appears multiple times in a file. *)
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
  (* Linear search through all stored items.
     Returns index if found, -1 if not found.
     O(n) complexity - fine for typical .env file sizes (<100 keys). *)
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
  // Simple wrapper around Find that returns the value or a default
  Idx := Find(AKey);
  if Idx >= 0 then
    Result := FItems[Idx].Value
  else
    Result := ADefault;
end;

procedure TDotEnvValues.Clear;
begin
  // Reset to empty state - releases memory held by dynamic array
  SetLength(FItems, 0);
  FCount := 0;
end;

function TDotEnvValues.Count: Integer;
begin
  Result := FCount;
end;

function TDotEnvValues.GetPair(AIndex: Integer): TDotEnvPair;
begin
  (* Safe accessor with bounds checking.
     Returns empty pair if index is out of bounds. *)
  if (AIndex >= 0) and (AIndex < FCount) then
    Result := FItems[AIndex]
  else
  begin
    Result.Key := '';
    Result.Value := '';
  end;
end;

(* =========================================================================
   TDotEnv Implementation
   -------------------------------------------------------------------------
   This is the main implementation section containing all the parsing logic,
   value retrieval, and utility methods.
   ========================================================================= *)

class function TDotEnv.Create: TDotEnv;
begin
  (* Initialize all fields to sensible defaults.
     Note: Advanced records don't have automatic initialization,
     so we must explicitly set up all fields. *)
  Result.FValues.Init;
  Result.FOptions := TDotEnvOptions.Default;
  Result.FLoaded := False;
  SetLength(Result.FLoadedFiles, 0);
end;

class function TDotEnv.CreateWithOptions(const AOptions: TDotEnvOptions): TDotEnv;
begin
  // Create with defaults, then apply custom options
  Result := TDotEnv.Create;
  Result.FOptions := AOptions;
end;

(*
  DetectQuote - Determines if a value is quoted and extracts the content
  -------------------------------------------------------------------------
  Given a raw value string (everything after the = sign), this method:
  1. Checks if the value starts with a quote character (" or ')
  2. If quoted: sets AQuoteChar and returns value with opening quote removed
  3. If unquoted: sets AQuoteChar to #0 and returns the trimmed value
  
  The closing quote is handled later by ParseValue or ParseMultiLine.
*)
function TDotEnv.DetectQuote(const AValue: string; out AQuoteChar: Char): string;
var
  Trimmed: string;
begin
  // Remove leading whitespace to find the actual start of the value
  Trimmed := TrimLeft(AValue);
  AQuoteChar := #0;  // Default: unquoted
  
  // Handle empty values
  if Length(Trimmed) = 0 then
  begin
    Result := '';
    Exit;
  end;
  
  // Check for quote characters at the start
  if (Trimmed[1] = '"') or (Trimmed[1] = '''') then
  begin
    AQuoteChar := Trimmed[1];  // Remember which quote type
    // Return everything after the opening quote
    Result := Copy(Trimmed, 2, Length(Trimmed) - 1);
  end
  else
    Result := Trimmed;  // Unquoted - return as-is
end;

(*
  ParseValue - Processes a raw value string based on its quote type
  -------------------------------------------------------------------------
  This method handles three cases:
  
  1. UNQUOTED (AQuoteChar = #0):
     - Strips inline comments (everything after #)
     - Trims trailing whitespace
     - Example: "value # comment" becomes "value"
  
  2. DOUBLE-QUOTED (AQuoteChar = '"'):
     - Processes escape sequences: \n, \r, \t, \\, \", \'
     - Stops at closing quote
     - Example: "hello\nworld" becomes "hello<newline>world"
  
  3. SINGLE-QUOTED (AQuoteChar = ''''):
     - Returns literal content (no escape processing)
     - Stops at closing quote
     - Example: 'hello\nworld' stays as "hello\nworld"
*)
function TDotEnv.ParseValue(const ARawValue: string; AQuoteChar: Char): string;
var
  I: Integer;
  InEscape: Boolean;  // True when previous char was backslash
  Ch: Char;
begin
  Result := '';
  
  // CASE 1: Unquoted value - just strip comments and trim
  if AQuoteChar = #0 then
  begin
    I := Pos('#', ARawValue);  // Find inline comment
    if I > 0 then
      Result := TrimRight(Copy(ARawValue, 1, I - 1))
    else
      Result := TrimRight(ARawValue);
    Exit;
  end;
  
  // CASE 2 & 3: Quoted values - process character by character
  InEscape := False;
  for I := 1 to Length(ARawValue) do
  begin
    Ch := ARawValue[I];
    
    if InEscape then
    begin
      // Previous char was backslash - process escape sequence
      case Ch of
        'n': Result := Result + #10;   // Newline
        'r': Result := Result + #13;   // Carriage return
        't': Result := Result + #9;    // Tab
        '\': Result := Result + '\';   // Literal backslash
        '"': Result := Result + '"';   // Literal double quote
        '''': Result := Result + ''''; // Literal single quote
      else
        // Unknown escape - keep both backslash and char
        Result := Result + '\' + Ch;
      end;
      InEscape := False;
    end
    else if (Ch = '\') and (AQuoteChar = '"') then
      // Start escape sequence (only for double quotes)
      InEscape := True
    else if Ch = AQuoteChar then
      // Found closing quote - stop processing
      Break
    else
      // Regular character - add to result
      Result := Result + Ch;
  end;
end;

(*
  ParseMultiLine - Handles values that span multiple lines
  -------------------------------------------------------------------------
  This is called when we detect a quoted value where the opening quote
  is found but the closing quote is not on the same line.
  
  Example .env file:
    PRIVATE_KEY="-----BEGIN RSA KEY-----
    MIIEpAIBAAKCAQEA...
    -----END RSA KEY-----"
  
  The method continues reading lines and appending them (with newlines)
  until it finds a line containing the closing quote character.
  
  Parameters:
    ALines: The full file content as a TStringList
    AIndex: Current line index (modified to point to last line read)
    AStartValue: Content from first line after opening quote
    AQuoteChar: The quote character to look for (' or ")
*)
function TDotEnv.ParseMultiLine(const ALines: TStringList; var AIndex: Integer;
  const AStartValue: string; AQuoteChar: Char): string;
var
  Line: string;
  EndPos: Integer;
begin
  Result := AStartValue;
  
  // Keep reading lines until we find closing quote or EOF
  while AIndex < ALines.Count - 1 do
  begin
    Inc(AIndex);
    Line := ALines[AIndex];
    
    // Look for closing quote on this line
    EndPos := Pos(AQuoteChar, Line);
    if EndPos > 0 then
    begin
      // Found closing quote - append content before it and stop
      Result := Result + #10 + Copy(Line, 1, EndPos - 1);
      Exit;
    end
    else
      // No closing quote - append entire line and continue
      Result := Result + #10 + Line;
  end;
  // If we get here, closing quote was never found - value includes rest of file
end;

(*
  ExpandVariable - Resolves a variable name to its value
  -------------------------------------------------------------------------
  This is a helper for InterpolateValue. Given a variable name, it looks
  up the value in this order:
  
  1. First check values we've already loaded (allows referencing
     variables defined earlier in the same .env file)
  2. Then check system environment variables
  
  Returns empty string if variable is not found in either place.
*)
function TDotEnv.ExpandVariable(const AVarName: string): string;
var
  Idx: Integer;
begin
  (* First check our loaded values - allows ${VAR} to reference
     variables defined earlier in the same .env file *)
  Idx := FValues.Find(AVarName);
  if Idx >= 0 then
    Result := FValues.GetPair(Idx).Value
  else
    // Not found locally - check system environment
    Result := SysUtils.GetEnvironmentVariable(AVarName);
end;

(*
  InterpolateValue - Replaces ${VAR} and $VAR with their values
  -------------------------------------------------------------------------
  This method scans a value string for variable references and replaces
  them with their resolved values. Two syntaxes are supported:
  
  1. ${VAR} - Brace syntax (recommended, unambiguous)
     Example: "Hello ${NAME}!" with NAME=World becomes "Hello World!"
  
  2. $VAR - Simple syntax (ends at first non-identifier char)
     Example: "Path: $HOME/docs" with HOME=/users/me becomes "Path: /users/me/docs"
     Valid identifier chars: A-Z, a-z, 0-9, underscore
  
  If FOptions.Interpolate is False, returns the value unchanged.
  
  IMPLEMENTATION NOTES:
  - Processes string character by character
  - When $ is found, determines which syntax and extracts variable name
  - Uses ExpandVariable to get the replacement value
  - Handles edge cases like $$ or invalid syntax by passing through literally
*)
function TDotEnv.InterpolateValue(const AValue: string): string;
var
  I, J, VarStart: Integer;
  VarName: string;
  InBrace: Boolean;
  Ch: Char;
begin
  // Skip interpolation if disabled in options
  if not FOptions.Interpolate then
  begin
    Result := AValue;
    Exit;
  end;
  
  Result := '';
  I := 1;
  
  // Process each character
  while I <= Length(AValue) do
  begin
    Ch := AValue[I];
    
    if Ch = '$' then
    begin
      // Found potential variable reference
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

(*
  ParseLine - Parses a single line from an .env file
  -------------------------------------------------------------------------
  This method handles the parsing of a single KEY=value line.
  It handles various formats:
  - Simple: KEY=value
  - With export: export KEY=value  
  - With quotes: KEY="value" or KEY='value'
  - With comments: KEY=value # comment
  
  Parameters:
    ALine: The raw line from the file
    AKey: Output - the parsed key name (with prefix if configured)
    AValue: Output - the parsed and processed value
  
  Returns True if line was parsed successfully, False for:
  - Empty lines
  - Comment lines (starting with #)
  - Lines without = sign
  - Lines with empty key
*)
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
  
  // Skip empty lines and full-line comments
  if (TrimmedLine = '') or (TrimmedLine[1] = '#') then
    Exit;
  
  (* Handle shell-compatible 'export' prefix
     This allows .env files to also be sourced in bash *)
  if AnsiStartsStr('export ', TrimmedLine) then
    TrimmedLine := Trim(Copy(TrimmedLine, 8, Length(TrimmedLine)));
  
  // Find the = separator between key and value
  EqPos := Pos('=', TrimmedLine);
  if EqPos = 0 then
    Exit;  // No = sign - invalid line
  
  // Extract the key (everything before =)
  AKey := Trim(Copy(TrimmedLine, 1, EqPos - 1));
  if AKey = '' then
    Exit;  // Empty key - invalid line
  
  // Apply prefix if configured (e.g., 'APP_' + 'KEY' = 'APP_KEY')
  if FOptions.Prefix <> '' then
    AKey := FOptions.Prefix + AKey;
  
  // Extract and parse the value (everything after =)
  RawValue := Copy(TrimmedLine, EqPos + 1, Length(TrimmedLine));
  RawValue := DetectQuote(RawValue, QuoteChar);
  AValue := ParseValue(RawValue, QuoteChar);
  
  Result := True;
end;

(*
  ApplyToEnvironment - Placeholder for setting system environment variables
  -------------------------------------------------------------------------
  Currently this method doesn't actually set system environment variables.
  Values are stored internally in FValues instead.
  
  FUTURE ENHANCEMENT:
  Could use platform-specific APIs to actually modify the process environment:
  - Windows: SetEnvironmentVariable
  - Unix: setenv()
  
  Note: Setting env vars at runtime only affects the current process and
  its children, not the parent shell or other processes.
*)
procedure TDotEnv.ApplyToEnvironment(const AKey, AValue: string);
var
  CurrentValue: string;
begin
  CurrentValue := SysUtils.GetEnvironmentVariable(AKey);
  
  if (CurrentValue = '') or FOptions.Override then
  begin
    {$IFDEF WINDOWS}
    // On Windows, could use Windows.SetEnvironmentVariable
    {$ENDIF}
    // Currently just stores in internal storage - see FValues
  end;
end;

(*
  Load - Loads environment variables from a .env file
  -------------------------------------------------------------------------
  This is the main entry point for loading configuration. It:
  1. Checks if file exists (silently returns False if not)
  2. Reads all lines from the file
  3. Parses each line, handling comments, quotes, multi-line values
  4. Applies variable interpolation
  5. Stores values in FValues
  6. Tracks the file in FLoadedFiles
  
  Parameters:
    APath: Path to .env file (defaults to '.env' in current directory)
  
  Returns:
    True if file was loaded successfully
    False if file doesn't exist (no exception thrown)
  
  Note: If Override option is False and a key already exists in system
  environment, the value from .env file is ignored for that key.
*)
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
  
  // Default to '.env' if no path specified
  if APath = '' then
    FullPath := '.env'
  else
    FullPath := APath;
  
  // Check if file exists - return False if not (no exception)
  if not FileExists(FullPath) then
  begin
    if FOptions.Verbose then
      WriteLn('DotEnv: File not found: ', FullPath);
    Exit;
  end;
  
  // Read the entire file into a TStringList for line-by-line processing
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(FullPath);
    
    // Process each line
    I := 0;
    while I < Lines.Count do
    begin
      TrimmedLine := Trim(Lines[I]);
      
      // Skip empty lines and full-line comments
      if (TrimmedLine = '') or (TrimmedLine[1] = '#') then
      begin
        Inc(I);
        Continue;
      end;
      
      // Handle shell-compatible 'export' prefix
      if AnsiStartsStr('export ', TrimmedLine) then
        TrimmedLine := Trim(Copy(TrimmedLine, 8, Length(TrimmedLine)));
      
      // Find '=' sign - required for valid KEY=value format
      EqPos := Pos('=', TrimmedLine);
      if EqPos = 0 then
      begin
        Inc(I);
        Continue;
      end;
      
      // Extract the key name
      Key := Trim(Copy(TrimmedLine, 1, EqPos - 1));
      if Key = '' then
      begin
        Inc(I);
        Continue;
      end;
      
      // Apply key prefix if configured
      if FOptions.Prefix <> '' then
        Key := FOptions.Prefix + Key;
      
      // Extract and parse the value
      RawValue := Copy(TrimmedLine, EqPos + 1, Length(TrimmedLine));
      RawValue := DetectQuote(RawValue, QuoteChar);
      
      // Check for multi-line value (quoted but no closing quote on this line)
      if (QuoteChar <> #0) and (Pos(QuoteChar, RawValue) = 0) then
        Value := ParseMultiLine(Lines, I, ParseValue(RawValue, #0), QuoteChar)
      else
        Value := ParseValue(RawValue, QuoteChar);
      
      // Perform variable interpolation (${VAR} and $VAR)
      Value := InterpolateValue(Value);
      
      // Check if we should skip this key (don't override existing env vars)
      if not FOptions.Override then
      begin
        if SysUtils.GetEnvironmentVariable(Key) <> '' then
        begin
          Inc(I);
          Continue;
        end;
      end;
      
      // Store the key-value pair
      FValues.Add(Key, Value);
      
      // Verbose output for debugging
      if FOptions.Verbose then
        WriteLn('DotEnv: Loaded ', Key, '=', Value);
      
      Inc(I);
    end;
    
    // Track which files have been loaded successfully
    SetLength(FLoadedFiles, Length(FLoadedFiles) + 1);
    FLoadedFiles[High(FLoadedFiles)] := FullPath;
    
    FLoaded := True;
    Result := True;
  finally
    // Always free the TStringList, even if an exception occurs
    Lines.Free;
  end;
end;

(*
  LoadFromStream - Loads environment variables from a TStream
  -------------------------------------------------------------------------
  Useful for loading from resources, network responses, or memory streams.
  Internally converts stream to string and delegates to LoadFromString.
*)
function TDotEnv.LoadFromStream(AStream: TStream): Boolean;
var
  Lines: TStringList;
  Content: string;
begin
  // Read stream content using TStringList
  Lines := TStringList.Create;
  try
    Lines.LoadFromStream(AStream);
    Content := Lines.Text;
  finally
    Lines.Free;
  end;
  
  // Delegate to LoadFromString for actual parsing
  Result := LoadFromString(Content);
end;

(*
  LoadFromString - Loads environment variables from a string
  -------------------------------------------------------------------------
  Perfect for testing or loading configuration from non-file sources.
  The string should be formatted like a .env file with one KEY=value per line.
  
  Example:
    Env.LoadFromString('KEY1=value1' + LineEnding + 'KEY2=value2');
*)
function TDotEnv.LoadFromString(const AContent: string): Boolean;
var
  Lines: TStringList;
  I: Integer;
  Key, Value, RawValue, TrimmedLine: string;
  QuoteChar: Char;
  EqPos: Integer;
begin
  Result := False;
  
  // Parse string into lines using TStringList
  Lines := TStringList.Create;
  try
    Lines.Text := AContent;
    
    // Process each line - same logic as Load
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
      
      // Extract key
      Key := Trim(Copy(TrimmedLine, 1, EqPos - 1));
      if Key = '' then
      begin
        Inc(I);
        Continue;
      end;
      
      // Apply prefix if set
      if FOptions.Prefix <> '' then
        Key := FOptions.Prefix + Key;
      
      // Extract and parse value
      RawValue := Copy(TrimmedLine, EqPos + 1, Length(TrimmedLine));
      RawValue := DetectQuote(RawValue, QuoteChar);
      
      // Check for multi-line value
      if (QuoteChar <> #0) and (Pos(QuoteChar, RawValue) = 0) then
        Value := ParseMultiLine(Lines, I, ParseValue(RawValue, #0), QuoteChar)
      else
        Value := ParseValue(RawValue, QuoteChar);
      
      // Perform variable interpolation
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

(*
  LoadMultiple - Loads multiple .env files in sequence
  -------------------------------------------------------------------------
  Files are loaded in order, with later files overriding values from
  earlier files. This is the standard pattern for environment-specific
  configuration:
  
  Example:
    Env.LoadMultiple(['.env', '.env.local', '.env.development']);
    (* .env has base config, .env.local overrides for this machine,
       .env.development overrides for dev environment *)
  
  Returns True if at least one file was loaded successfully.
*)
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

(* =========================================================================
   GETTER METHODS
   -------------------------------------------------------------------------
   These methods retrieve values with various type conversions.
   Each has a standard version (returns default if missing/invalid)
   and a Required version (raises exception if missing/invalid).
   ========================================================================= *)

function TDotEnv.Get(const AKey: string; const ADefault: string): string;
var
  Idx: Integer;
begin
  // First check our loaded values
  Idx := FValues.Find(AKey);
  if Idx >= 0 then
    Result := FValues.GetPair(Idx).Value
  else
  begin
    // Not found locally - check system environment as fallback
    Result := SysUtils.GetEnvironmentVariable(AKey);
    if Result = '' then
      Result := ADefault;  // Use provided default as last resort
  end;
end;

function TDotEnv.GetRequired(const AKey: string): string;
begin
  Result := Get(AKey, '');
  if Result = '' then
    // Key not found anywhere - raise exception with helpful message
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
    // Try to convert to integer, use default if conversion fails
    if not TryStrToInt(S, Result) then
      Result := ADefault;
  end;
end;

function TDotEnv.GetIntRequired(const AKey: string): Integer;
var
  S: string;
begin
  S := GetRequired(AKey);  // This throws if key missing
  if not TryStrToInt(S, Result) then
    // Key exists but value isn't a valid integer
    raise EDotEnvParseError.CreateFmt('Cannot convert %s to integer: %s', [AKey, S]);
end;

function TDotEnv.GetBool(const AKey: string; const ADefault: Boolean): Boolean;
var
  S: string;
begin
  // Get value and normalize to lowercase for comparison
  S := LowerCase(Trim(Get(AKey, '')));
  if S = '' then
    Result := ADefault
  else
    // Recognize common truthy values - everything else is false
    Result := (S = 'true') or (S = '1') or (S = 'yes') or (S = 'on');
end;

function TDotEnv.GetBoolRequired(const AKey: string): Boolean;
var
  S: string;
begin
  S := LowerCase(Trim(GetRequired(AKey)));
  (* Note: doesn't validate that value is actually a boolean-like string.
     Any non-truthy value returns False. *)
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
    // TryStrToFloat handles locale-specific decimal separators
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

(*
  GetArray - Splits a value into an array by separator
  -------------------------------------------------------------------------
  Useful for comma-separated lists like:
    ALLOWED_HOSTS=localhost,127.0.0.1,example.com
    FEATURES=auth,logging,cache
  
  Each element is trimmed of whitespace.
  Returns empty array if key not found.
*)
function TDotEnv.GetArray(const AKey: string; const ASeparator: string): TStringDynArray;
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
  
  // Use TStringList's built-in delimiter parsing
  Parts := TStringList.Create;
  try
    Parts.Delimiter := ASeparator[1];    // Only uses first char of separator
    Parts.StrictDelimiter := True;       // Don't treat spaces as delimiters
    Parts.DelimitedText := S;
    
    // Copy to result array, trimming each element
    SetLength(Result, Parts.Count);
    for I := 0 to Parts.Count - 1 do
      Result[I] := Trim(Parts[I]);
  finally
    Parts.Free;
  end;
end;

(* =========================================================================
   UTILITY METHODS
   ========================================================================= *)

function TDotEnv.Has(const AKey: string): Boolean;
begin
  // Check both loaded values AND system environment
  Result := (FValues.Find(AKey) >= 0) or 
            (SysUtils.GetEnvironmentVariable(AKey) <> '');
end;

(*
  Keys - Returns all loaded key names as an array
  -------------------------------------------------------------------------
  Useful for iteration, debugging, or discovering what variables are loaded.
  Only includes keys from .env files, NOT system environment variables.
*)
function TDotEnv.Keys: TStringDynArray;
var
  I: Integer;
begin
  SetLength(Result, FValues.Count);
  for I := 0 to FValues.Count - 1 do
    Result[I] := FValues.GetPair(I).Key;
end;

(*
  Values - Returns all loaded values as an array
  -------------------------------------------------------------------------
  Parallel to Keys - same index gives corresponding key/value pair.
*)
function TDotEnv.Values: TStringDynArray;
var
  I: Integer;
begin
  SetLength(Result, FValues.Count);
  for I := 0 to FValues.Count - 1 do
    Result[I] := FValues.GetPair(I).Value;
end;

(*
  AsArray - Returns all key-value pairs as TDotEnvPair array
  -------------------------------------------------------------------------
  Provides record-based access to all loaded variables.
  Useful for serialization or batch operations.
*)
function TDotEnv.AsArray: TDotEnvPairArray;
var
  I: Integer;
begin
  SetLength(Result, FValues.Count);
  for I := 0 to FValues.Count - 1 do
    Result[I] := FValues.GetPair(I);
end;

// Returns the number of loaded environment variables
function TDotEnv.Count: Integer;
begin
  Result := FValues.Count;
end;

(* =========================================================================
   VALIDATION METHODS - Check for required configuration
   ========================================================================= *)

(*
  Validate - Check if all required keys are present
  -------------------------------------------------------------------------
  Usage:
    if not Env.Validate(['DB_HOST', 'DB_NAME', 'SECRET_KEY']) then
      raise Exception.Create('Missing required configuration!');
  
  Returns True only if ALL specified keys have values.
  Uses Has() internally, so checks both .env and system environment.
*)
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
      Exit;  // Fail fast on first missing key
    end;
  end;
end;

(*
  GetMissing - Returns array of missing required keys
  -------------------------------------------------------------------------
  More informative than Validate - tells you exactly WHAT is missing.
  
  Usage:
    Missing := Env.GetMissing(['DB_HOST', 'DB_NAME', 'API_KEY']);
    if Length(Missing) > 0 then
      WriteLn('Missing: ', String.Join(', ', Missing));
  
  Returns empty array if all keys are present.
*)
function TDotEnv.GetMissing(const ARequiredKeys: array of string): TStringDynArray;
var
  I, MissingCount: Integer;
  Temp: TStringDynArray;
begin
  // Pre-allocate maximum possible size
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
  
  // Shrink to actual count of missing keys
  SetLength(Result, MissingCount);
  for I := 0 to MissingCount - 1 do
    Result[I] := Temp[I];
end;

(* =========================================================================
   ENVIRONMENT MODIFICATION METHODS
   ========================================================================= *)

(*
  SetToEnv - Add or update a value in the loaded environment
  -------------------------------------------------------------------------
  Only modifies the in-memory storage, NOT the actual .env file.
  Useful for runtime configuration or overriding loaded values.
*)
procedure TDotEnv.SetToEnv(const AKey, AValue: string);
begin
  FValues.Add(AKey, AValue);
end;

(*
  GetFromEnv - Read directly from system environment variables
  -------------------------------------------------------------------------
  Bypasses loaded .env values, reads only from OS environment.
  Useful when you need to distinguish between .env and system variables.
*)
function TDotEnv.GetFromEnv(const AKey: string; const ADefault: string): string;
begin
  Result := SysUtils.GetEnvironmentVariable(AKey);
  if Result = '' then
    Result := ADefault;
end;

(*
  ToString - Serialize all loaded values back to .env format
  -------------------------------------------------------------------------
  Returns a string like:
    KEY1=value1
    KEY2=value2
  
  Useful for debugging, logging, or saving modified configuration.
  Note: Does not include system environment variables.
*)
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
      Result := Result + LineEnding;  // Platform-independent line ending
    Result := Result + Pair.Key + '=' + Pair.Value;
  end;
end;

(*
  LoadedFiles - Returns list of all .env files that were loaded
  -------------------------------------------------------------------------
  Useful for debugging to see which files contributed to current config.
  Files are listed in the order they were loaded.
*)
function TDotEnv.LoadedFiles: TStringDynArray;
begin
  Result := FLoadedFiles;
end;

(* =========================================================================
   GLOBAL HELPER FUNCTIONS - Convenience API for simple use cases
   =========================================================================
   These functions provide a simpler API when you don't need multiple
   TDotEnv instances. They use a shared global instance that is created
   on first use and persists for the lifetime of the program.
   
   Typical usage:
     DotEnvLoad('.env');                     // Load at startup
     Value := DotEnvGet('DATABASE_URL', ''); // Use anywhere in code
     DotEnvSet('RUNTIME_FLAG', 'true');      // Modify at runtime
   ========================================================================= *)

(*
  DotEnvLoad - Load a .env file into the global instance
  -------------------------------------------------------------------------
  Creates the global instance if needed, then loads the specified file.
  Returns the global TDotEnv instance for method chaining.
  
  If you need to load multiple files:
    DotEnvLoad('.env').Load('.env.local');
*)
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

(*
  DotEnvGet - Get a value from the global instance
  -------------------------------------------------------------------------
  Auto-loads '.env' if no file has been loaded yet.
  This allows you to call DotEnvGet() without explicit DotEnvLoad().
*)
function DotEnvGet(const AKey: string; const ADefault: string): string;
begin
  if not GlobalDotEnvInitialized then
  begin
    GlobalDotEnv := TDotEnv.Create;
    GlobalDotEnv.Load;  // Auto-load default '.env' file
    GlobalDotEnvInitialized := True;
  end;
  Result := GlobalDotEnv.Get(AKey, ADefault);
end;

(*
  DotEnvSet - Set a value in the global instance
  -------------------------------------------------------------------------
  Creates the global instance if needed (but doesn't auto-load any file).
  Useful for setting runtime configuration or test values.
*)
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

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$RepoRoot = [IO.Path]::GetFullPath($PSScriptRoot)
$ExamplesRoot = Join-Path $RepoRoot 'examples'
$OutputRoot = [IO.Path]::GetFullPath((Join-Path $RepoRoot 'examples-bin'))
$ExpectedOutputRoot = [IO.Path]::GetFullPath((Join-Path $RepoRoot 'examples-bin'))

if (-not $OutputRoot.Equals(
    $ExpectedOutputRoot, [StringComparison]::OrdinalIgnoreCase)) {
  throw "Refusing unexpected output path: $OutputRoot"
}

if (Test-Path -LiteralPath $OutputRoot) {
  $ResolvedOutput = (Resolve-Path -LiteralPath $OutputRoot).Path
  if (-not $ResolvedOutput.Equals(
      $ExpectedOutputRoot, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to clean unexpected path: $ResolvedOutput"
  }
  Remove-Item -LiteralPath $ResolvedOutput -Recurse -Force
}

New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null

$null = Get-Command lazbuild -ErrorAction Stop
$Projects = @(
  Get-ChildItem -LiteralPath $ExamplesRoot -Directory |
    ForEach-Object {
      Get-ChildItem -LiteralPath $_.FullName -Filter '*.lpi' -File
    } |
    Sort-Object FullName
)

if ($Projects.Count -eq 0) {
  throw 'No canonical Lazarus example projects were found.'
}

$ExecutableExtension = if ($env:OS -eq 'Windows_NT') { '.exe' } else { '' }

foreach ($Project in $Projects) {
  $Name = [IO.Path]::GetFileNameWithoutExtension($Project.Name)
  $UnitOutput = Join-Path (Join-Path $OutputRoot 'units') $Name
  New-Item -ItemType Directory -Path $UnitOutput -Force | Out-Null

  Write-Host "Building $Name"
  & lazbuild `
    --build-all `
    --build-mode=Release `
    --no-write-project `
    "--opt=-FE$OutputRoot" `
    "--opt=-FU$UnitOutput" `
    '--opt=-FcUTF8' `
    $Project.FullName

  if ($LASTEXITCODE -ne 0) {
    throw "Failed to build $($Project.FullName)"
  }

  $Executable = Join-Path $OutputRoot ($Name + $ExecutableExtension)
  if (-not (Test-Path -LiteralPath $Executable)) {
    throw "Build succeeded but executable was not found: $Executable"
  }
}

Write-Host "Built $($Projects.Count) examples in $OutputRoot"

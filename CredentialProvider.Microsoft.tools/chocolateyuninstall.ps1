$ErrorActionPreference = 'Stop';

$installDir    = Join-Path $env:USERPROFILE "\.nuget\plugins"

if (Test-Path -Path "$installDir\netfx")
{
   Remove-Item "$installDir\netfx" -Recurse
}

if (Test-Path -Path "$installDir\netcore")
{
   Remove-Item "$installDir\netcore" -Recurse
}
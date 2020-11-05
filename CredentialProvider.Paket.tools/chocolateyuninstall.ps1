$ErrorActionPreference = 'Stop';

$installDir    = Join-Path $env:LOCALAPPDATA "Nuget\CredentialProviders"

if (Test-Path -Path "$installDir\CredentialProvider.Paket")
{
   Remove-Item "$installDir\CredentialProvider.Paket" -Recurse
}
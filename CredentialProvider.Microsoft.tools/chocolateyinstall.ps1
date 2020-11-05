$ErrorActionPreference = 'Stop'; # stop on all errors

$packageName   = 'Nuget.CredentialProvider.Microsoft'
$toolsDir      = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url           = 'https://github.com/microsoft/artifacts-credprovider/releases/download/v0.1.24/Microsoft.NuGet.CredentialProvider.zip'
$installDir    = Join-Path $env:USERPROFILE "\.nuget\plugins"

## Download and unpack the zip file:
$downloadedZip = Join-Path $toolsDir 'Microsoft.NuGet.CredentialProvider.zip'
Get-ChocolateyWebFile -PackageName "$packageName" -FileFullPath "$downloadedZip" -Url "$url" -Checksum "4E19D0BFEE4FEC43C324C7B5B4529E9B54E269E534295E4E9804E18AB4C3B234" -ChecksumType "sha256"
Get-ChocolateyUnzip -FileFullPath "$downloadedZip" -Destination "$toolsDir"

if (!(Test-Path -Path "$installDir"))
{
   New-Item -ItemType directory -Path "$installDir"
}

Copy-Item "$toolsDir\plugins\netcore" "$installDir" -Force -Recurse
Copy-Item "$toolsDir\plugins\netfx" "$installDir" -Force -Recurse
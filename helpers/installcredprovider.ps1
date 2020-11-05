# A PowerShell script that adds the latest version of the Azure Artifacts credential provider
# plugin for Dotnet and/or NuGet to ~/.nuget/plugins directory
# To install credprovider, run installcredprovider.ps1
# To overwrite existing plugin with the latest version, run installcredprovider.ps1 -Force
# To use a specific version of a credential provider, run installcredprovider.ps1 -Version "0.1.17" or installcredprovider.ps1 -Version "0.1.17" -Force
# More: https://github.com/Microsoft/artifacts-credprovider/blob/master/README.md

param(
    # override existing cred provider with the latest version
    [switch]$Force,
    # install the version specified
    [string]$Version
)

$script:ErrorActionPreference='Stop'

# Without this, System.Net.WebClient.DownloadFile will fail on a client with TLS 1.0/1.1 disabled
if ([Net.ServicePointManager]::SecurityProtocol.ToString().Split(',').Trim() -notcontains 'Tls12') {
    [Net.ServicePointManager]::SecurityProtocol += [Net.SecurityProtocolType]::Tls12
}

$localAppDataPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::LocalApplicationData)
$tempPath = [System.IO.Path]::GetTempPath()

$pluginLocation = [System.IO.Path]::Combine($localAppDataPath, "NuGet", "CredentialProviders");
$tempZipLocation = [System.IO.Path]::Combine($tempPath, "CredProviderZip");

$localCredProviderPath = [System.IO.Path]::Combine("CredentialProvider.Paket");
$fullCredProviderPath = [System.IO.Path]::Combine($pluginLocation, $localCredProviderPath)

$credProviderExists = Test-Path -Path ($fullCredProviderPath)

# Check if plugin already exists if -Force swich is not set
if (!$Force) {
    if ($credProviderExists -eq $True) {
        Write-Host "The Credential Provider are already in $pluginLocation"
        return
    }
}

# Get the zip file from the GitHub release
$releaseUrlBase = "https://api.github.com/repos/ehhnwidex/CredentialProvider.Paket/releases/"
$versionError = "Unable to find the release version $Version from $releaseUrlBase"
$releaseId = "latest"
if (![string]::IsNullOrEmpty($Version)) {
    try {
        $releases = Invoke-WebRequest -UseBasicParsing $releaseUrlBase
        $releaseJson = $releases | ConvertFrom-Json
        $correctReleaseVersion = $releaseJson | ? { $_.name -eq $Version }
        $releaseId = $correctReleaseVersion.id
    } catch {
        Write-Error $versionError
        return
    }
}

if (!$releaseId) {
    Write-Error $versionError
    return
}

$releaseUrl = [System.IO.Path]::Combine($releaseUrlBase, $releaseId)
$releaseUrl = $releaseUrl.Replace("\","/")

$zipFile = "CredentialProvider.Paket.zip"
Write-Verbose "Using $zipFile"

$zipErrorString = "Unable to resolve the Credential Provider zip file from $releaseUrl"
try {
    Write-Host "Fetching release $releaseUrl"
    $release = Invoke-WebRequest -UseBasicParsing $releaseUrl
    $releaseJson = $release.Content | ConvertFrom-Json
    $zipAsset = $releaseJson.assets | ? { $_.name -eq $zipFile }
    $packageSourceUrl = $zipAsset.browser_download_url
} catch {
    Write-Error $zipErrorString
    return
}

if (!$packageSourceUrl) {
    Write-Error $zipErrorString
    return
}

# Create temporary location for the zip file handling
Write-Verbose "Creating temp directory for the Credential Provider zip: $tempZipLocation"
if (Test-Path -Path $tempZipLocation) {
    Remove-Item $tempZipLocation -Force -Recurse
}
New-Item -ItemType Directory -Force -Path $tempZipLocation

# Download credential provider zip to the temp location
$pluginZip = ([System.IO.Path]::Combine($tempZipLocation, $zipFile))
Write-Host "Downloading $packageSourceUrl to $pluginZip"
try {
    $client = New-Object System.Net.WebClient
    $client.DownloadFile($packageSourceUrl, $pluginZip)
} catch {
    Write-Error "Unable to download $packageSourceUrl to the location $pluginZip"
}

# Extract zip to temp directory
Write-Host "Extracting zip to the Credential Provider temp directory $tempZipLocation"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($pluginZip, $tempZipLocation)

# Remove existing content and copy credprovider directories to plugins directory
if ($credProviderExists) {
    Write-Verbose "Removing existing content from $fullCredProviderPath"
    Remove-Item $fullCredProviderPath -Force -Recurse
}
$tempCredProviderPath = [System.IO.Path]::Combine($tempZipLocation, $localCredProviderPath)
Write-Verbose "Copying Credential Provider from $tempCredProviderPath to $fullCredProviderPath"
Copy-Item $tempCredProviderPath -Destination $fullCredProviderPath -Force -Recurse

# Remove $tempZipLocation directory
Write-Verbose "Removing the Credential Provider temp directory $tempZipLocation"
Remove-Item $tempZipLocation -Force -Recurse

Write-Host "Credential Provider installed successfully"
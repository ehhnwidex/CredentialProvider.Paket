$scriptPath = $PSScriptRoot
Set-Location $scriptPath
dotnet tool restore
dotnet tool run dotnet-cake
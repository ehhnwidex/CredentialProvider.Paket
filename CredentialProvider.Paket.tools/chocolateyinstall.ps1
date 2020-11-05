$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path -Path $toolsDir  -ChildPath CredentialProvider.Paket.exe

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'exe' #only one of these: exe, msi, msu
  file          = $fileLocation
  softwareName  = 'CredentialProvider.Paket*' #part or all of the Display Name as you see it in Programs and Features. It should be enough to be unique

  checksum      = '976064823C892C53F5391E34BCEB5D56FA4F530CE9768F5579612C3039CF75E2'
  checksumType  = 'sha256' #default is md5, can also be sha1, sha256 or sha512

  silentArgs   = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-' # Inno Setup
  validExitCodes= @(0, 3010, 1641)
 
}

Install-ChocolateyPackage @packageArgs # https://chocolatey.org/docs/helpers-install-chocolatey-package

[Setup]
AppName = CredentialProvider.Paket
AppVerName = 1.0
DefaultDirName = "{localappdata}\NuGet\CredentialProviders\"
OutputBaseFilename = CredentialProvider.Paket
OutputDir=CredentialProvider.Paket.tools
PrivilegesRequired=lowest

[Files]
Source: bin\Release\netcoreapp2.1\CredentialProvider.Paket\*; DestDir: {localappdata}\NuGet\CredentialProviders\CredentialProvider.Paket\; Flags: ignoreversion createallsubdirs recursesubdirs comparetimestamp 
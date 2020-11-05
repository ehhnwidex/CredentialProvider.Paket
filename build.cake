#tool "nuget:?package=Tools.InnoSetup&version=6.0.5"
//Primary arguments
var target = Argument("target", "Default");
var configuration = Argument("Configuration", "Release");
var projects = Context.FileSystem.GetDirectory(".").GetFiles("*.csproj", SearchScope.Recursive);

Task("Default")
  .IsDependentOn("Publish")
  .IsDependentOn("Build-Installer")
  .IsDependentOn("Pack")
  .Does(() =>
{
});

Task("Restore")
  .Does(() => 
{
  foreach(var project in projects)
  {
    DotNetCoreClean(project.Path.FullPath);
  }
});

  
Task("Clean")
  .Does(() => 
{
  foreach(var project in projects)
  {
    var settings = new DotNetCoreCleanSettings
    {
      Configuration = configuration,
    };
    DotNetCoreClean(project.Path.FullPath, settings);
  }
});


Task("Build")
  .Does(() => 
{
  foreach(var project in projects)
  {
    var settings = new DotNetCoreBuildSettings
	  {
		  Configuration = configuration,
	  };
	  DotNetCoreBuild(project.Path.FullPath, settings);
  }
});

Task("Pack")
  .WithCriteria(() => configuration.ToLower() == "release")
  .Does(() => 
{
    CreateDirectory("./artifacts");
    // Create choco packages
    var settings = new ChocolateyPackSettings
	  {
		  OutputDirectory = Directory("./artifacts"),
	  };
    var nuspecFiles = GetFiles("./*.nuspec");
    ChocolateyPack(nuspecFiles, settings);
    
    //Create a zip publish file
    Zip("./bin/Release/netcoreapp2.1", "./artifacts/CredentialProvider.Paket.zip");
});

Task("Build-Installer")
  .WithCriteria(() => configuration.ToLower() == "release")
  .Does(() => 
{
     InnoSetup("./CredentialProvider.Paket.iss");
});

Task("Publish")
  .Does(() => {
    foreach(var project in projects)
    {    
      var settings = new DotNetCorePublishSettings
      { 
        Configuration = configuration,
        ArgumentCustomization = args=>args.Append("/p:PublishProfile=" + configuration)
      };
      DotNetCorePublish(project.Path.FullPath, settings);
    }
  });

RunTarget(target);
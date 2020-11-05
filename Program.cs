using Microsoft.Extensions.CommandLineUtils;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;

namespace CredentialProvider.Paket
{
    class Program
    {
        const string HelpFlag = "--help";
        const string Uri = "-u |-Uri|-uri";
        const string NonInteractive = "-n|-NonInteractive";
        const string Verbosity = "-v|-Verbosity";
        const string IsRetry = "-i|--IsRetry";

        static int Main(string[] args)
        {
            try
            {
                return Run(args);
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return 0xbad;
            }
        }

        private static int Run(string[] args)
        {
            var app = new CommandLineApplication(throwOnUnexpectedArg: false);
            
            // Enable help options
            var SetHelpFlag = app.HelpOption(HelpFlag);
            var SetUri = app.Option(Uri, "The package source URI for which credentials will be filled", CommandOptionType.SingleValue);
            var SetVerbosity = app.Option(Verbosity, @"Display this amount of detail in the output [Default='Information']
                      Debug
                      Verbose
                      Information
                      Minimal
                      Warning
                      Error", CommandOptionType.SingleValue);
            var SetNonInteractive = app.Option(NonInteractive, "If present and true, providers will not issue interactive prompts", CommandOptionType.NoValue);
            var SetIsRetry = app.Option(IsRetry, @"If false / unset, INVALID CREDENTIALS MAY BE RETURNED. The caller is required to validate
                      returned credentials themselves, and if invalid, should call the credential provider again
                      with - IsRetry set.If true, the credential provider will obtain new credentials instead of
                      returning potentially invalid credentials from the cache.", CommandOptionType.NoValue);
            // Display help function


            app.OnExecute(() =>
            {
                //if (app.RemainingArguments.Count != 0)
                //{
                //    SetUri.Values.Add(app.RemainingArguments[0]);
                //}

                if (SetHelpFlag.HasValue() || !SetUri.HasValue())
                {
                    app.ShowHelp();
                    return 0;
                }
                               
                List<String> arguments = new List<string>();
                arguments.Add(String.Format("-Uri {0}", SetUri.Value()));
                arguments.Add("-F json");

                if (SetNonInteractive.HasValue())
                {
                    arguments.Add("-n");
                }
                if (SetIsRetry.HasValue())
                {
                    arguments.Add("-i");
                }

                if (SetVerbosity.HasValue())
                {
                    arguments.Add(String.Format("-V {0}", SetVerbosity.Value()));
                }
                ProcessStartInfo processInfo = new ProcessStartInfo();
                StringBuilder argumentsBuilder = new StringBuilder();
                argumentsBuilder.AppendJoin(" ", arguments.ToArray());

                var exeFile = "CredentialProvider.Microsoft.exe";
                var nugetPluiginPath = Environment.GetEnvironmentVariable("NUGET_PLUGIN_PATHS");
                if (String.IsNullOrEmpty(nugetPluiginPath))
                {
                    nugetPluiginPath = Environment.GetEnvironmentVariable("UserProfile");
                } 
                
                var path = String.Format(@"{0}\.nuget\plugins\netfx\CredentialProvider.Microsoft\", nugetPluiginPath);
                var runnable = Path.Combine(path, exeFile);
                processInfo.FileName = runnable;
                processInfo.Arguments = argumentsBuilder.ToString();
                processInfo.UseShellExecute = false;
                processInfo.RedirectStandardOutput = true;

                try {
                    using (Process exeProcess = Process.Start(processInfo))
                    {
                        using (StreamReader reader = exeProcess.StandardOutput)
                        {
                            string result = reader.ReadToEnd();
                            Console.Write(result);
                        }
                    }
                }
                    catch (Exception e)
                {
                    Console.WriteLine(String.Format("An error occoured: {0}", e.Message));
                    return 1;
                }
                return 0;
                
            });

            return app.Execute(args);
        }
    }
}

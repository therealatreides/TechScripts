using System;
using System.IO;
using Publisher = Microsoft.Office.Interop.Publisher;

namespace Pub2PDF
{
    
    class Program
    {
        static void Main(string[] args)
        {
            string sourceDir;

            if (args.Length > 0)
            {
                sourceDir = args[0];

                if (!Directory.Exists(sourceDir))
                {
                    Console.WriteLine("Source directory not found.");
                    Environment.Exit(0);
                }

                Publisher.Application pubApplication = new Publisher.Application();
                pubApplication.ActiveWindow.Visible = false;

                foreach (string pubFile in Directory.EnumerateFiles(sourceDir, "*.pub"))
                {
                    Publisher.Document document = pubApplication.Open(pubFile, false, true, Publisher.PbSaveOptions.pbPromptToSaveChanges);
                    string pdfFile = Path.ChangeExtension(pubFile, "pdf");
                    document.ExportAsFixedFormat(Publisher.PbFixedFormatType.pbFixedFormatTypePDF, pdfFile);
                    document.Save();
                    document.Close();
                }

                pubApplication.Quit();
            }
            else
            {
                Console.WriteLine("No command line arguments found.");
            }

        }
    }
}

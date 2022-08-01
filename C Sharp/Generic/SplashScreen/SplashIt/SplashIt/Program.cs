using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SplashIt
{
    static class Program
    {
        private static string pageURL = @"\\localhost\share\index.htm";
        private static string app2Mon = "kix32.exe";
        private static int width = 630;
        private static int height = 480;

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            // To check the length of 
            // Command line arguments  
            if (args.Length == 0 || args.Contains("--help", StringComparer.OrdinalIgnoreCase) || args.Contains("-h", StringComparer.OrdinalIgnoreCase))
            {
                string msgText = "Help Requested by the Admin:"+Environment.NewLine+ Environment.NewLine;
                msgText += "SplashIt <flags> <options>" + Environment.NewLine;
                msgText += Environment.NewLine;
                msgText += "Flags (optional):" + Environment.NewLine;
                msgText += "--help, -h      : View this message" + Environment.NewLine;
                msgText += Environment.NewLine;
                msgText += "Options (required):" + Environment.NewLine;
                msgText += "<process>       : Process name to monitor for" + Environment.NewLine;
                msgText += "<splash file>   : HTML based file to use as a loading/splash screen" + Environment.NewLine;
                msgText += "<width>         : Width of the window" + Environment.NewLine;
                msgText += "<height>        : Height of the window" + Environment.NewLine;
                msgText += Environment.NewLine;
                msgText += "Examples:" + Environment.NewLine;
                msgText += @"Z:\SplashIt.exe kix32.exe Z:\Splash.html 630 480" + Environment.NewLine;
                msgText += "Z:\\SplashIt.exe kix32.exe \"Z:\\My Splashes\\Splash.html\" 630 480" + Environment.NewLine;

                MessageBox.Show(msgText);
                Environment.Exit(0);
            }
            else if (args.Length < 4)
            {
                string msgText = "Arguments missing. Please use --help or no options to see help." + Environment.NewLine;
                MessageBox.Show(msgText);
                Environment.Exit(0);
            }
            else
            {
                pageURL = args[0];
                app2Mon = args[1];
                width = Convert.ToInt32(args[2]);
                height = Convert.ToInt32(args[3]);
            }

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new SplashForm(pageURL, app2Mon, width, height));
        }
    }
}

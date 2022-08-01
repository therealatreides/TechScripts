using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SplashIt
{
    public partial class SplashForm : Form
    {
        private string splashUrl = string.Empty;
        private string splashApp = string.Empty;
        private int splashWidth = 0;
        private int splashHeight = 0;

        public SplashForm(string app2Mon, string pageUrl, int swidth, int sheight)
        {
            splashApp = app2Mon;
            splashUrl = pageUrl;
            splashWidth = swidth;
            splashHeight = sheight;
            InitializeComponent();
        }

        private void SplashForm_Load(object sender, EventArgs e)
        {
            this.Size = new Size(splashWidth, splashHeight);
            browserControl.Navigate(this.splashUrl);

            BackgroundWorker worker = new BackgroundWorker();
            worker.DoWork += Worker_DoWork;
            worker.ProgressChanged += Worker_ProgressChanged;
            worker.WorkerReportsProgress = false;
            worker.RunWorkerCompleted += Worker_RunWorkerCompleted;

            worker.RunWorkerAsync(this.splashApp);
        }

        private void SplashForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            // Check to see if the application is still running. If so, don't allow it to close. Otherwise, do nothing.
            // Remember, the Process Name is not the filename
            bool isRunning = Process.GetProcessesByName(splashApp).Length > 0;
            if (!isRunning)
            {
                // App being monitored is not running anymore. So do any SplashScreen Cleanup and go on so it can close out.
            }
            else
            {
                e.Cancel = true;
            }
        }

        private void Worker_DoWork(object sender, DoWorkEventArgs e)
        {
            //DoWork is the most important event. It is where the actual calculations are done.
            string appName = (string)e.Argument;
            bool isRunning = Process.GetProcessesByName(appName).Length > 0;
            do
            {
                Thread.Sleep(1250);
                isRunning = Process.GetProcessesByName(appName).Length > 0;
            }
            while (isRunning);
        }

        private void Worker_ProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            // Nothing to do here for this one.
        }

        private void Worker_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            //This method is optional but very useful. 
            //It is called once Worker_DoWork has finished.
            this.Close();
        }
    }
}

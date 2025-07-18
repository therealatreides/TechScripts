﻿using System.Drawing;
using System.Windows.Forms;

namespace CFControls.Forms
{
    public partial class SplashScreenForm : Form
    {
        delegate void StringParameterDelegate(string Text);
        delegate void StringParameterTitleDelegate(string Text);
        delegate void StringParameterDescDelegate(string Text);
        delegate void StringParameterWithStatusDelegate(string Text, TypeOfMessage tom);
        delegate void SplashShowCloseDelegate();

        /// <summary>
        /// To ensure splash screen is closed using the API and not by keyboard or any other things
        /// </summary>
        bool CloseSplashScreenFlag = false;

        public SplashScreenForm()
        {
            InitializeComponent();
            pictureBox1.Image = Image.FromFile(Application.StartupPath + @"\Data\logo.png");

            var posPBox = this.PointToScreen(pictureBox1.Location);
            posPBox = panel1.PointToClient(posPBox);
            pictureBox1.Parent = panel1;
            pictureBox1.Location = posPBox;

            var posTitle = this.PointToScreen(lblSplashTitle.Location);
            posTitle = pictureBox1.PointToClient(posTitle);
            lblSplashTitle.Parent = pictureBox1;
            lblSplashTitle.Location = posTitle;
            lblSplashTitle.BackColor = Color.Transparent;

            var posDesc = this.PointToScreen(lblDescription.Location);
            posDesc = pictureBox1.PointToClient(posDesc);
            lblDescription.Parent = pictureBox1;
            lblDescription.Location = posDesc;
            lblDescription.BackColor = Color.Transparent;

            var posStatus = this.PointToScreen(label1.Location);
            posStatus = pictureBox1.PointToClient(posStatus);
            label1.Parent = pictureBox1;
            label1.Location = posStatus;
            label1.BackColor = Color.Transparent;

            progressBar1.Show();

            this.TopMost = false;
        }

        /// <summary>
        /// Displays the splashscreen
        /// </summary>
        public void ShowSplashScreen()
        {
            if (InvokeRequired)
            {
                // We're not in the UI thread, so we need to call BeginInvoke
                BeginInvoke(new SplashShowCloseDelegate(ShowSplashScreen));
                return;
            }
            this.Show();
            Application.Run(this);
        }

        /// <summary>
        /// Closes the SplashScreen
        /// </summary>
        public void CloseSplashScreen()
        {
            if (InvokeRequired)
            {
                // We're not in the UI thread, so we need to call BeginInvoke
                BeginInvoke(new SplashShowCloseDelegate(CloseSplashScreen));
                return;
            }
            CloseSplashScreenFlag = true;
            this.Close();
        }

        /// <summary>
        /// Update text in title message
        /// </summary>
        /// <param name="Text">Message</param>
        public void UdpateTitleText(string Text)
        {
            if (InvokeRequired)
            {
                // We're not in the UI thread, so we need to call BeginInvoke
                BeginInvoke(new StringParameterTitleDelegate(UdpateTitleText), new object[] { Text });
                return;
            }
            // Must be on the UI thread if we've got this far
            lblSplashTitle.Text = Text;
        }

        /// <summary>
        /// Update text in description message
        /// </summary>
        /// <param name="Text">Message</param>
        public void UdpateDescText(string Text)
        {
            if (InvokeRequired)
            {
                // We're not in the UI thread, so we need to call BeginInvoke
                BeginInvoke(new StringParameterDescDelegate(UdpateDescText), new object[] { Text });
                return;
            }
            // Must be on the UI thread if we've got this far
            lblDescription.Text = Text;
        }

        /// <summary>
        /// Update text in default green color of success message
        /// </summary>
        /// <param name="Text">Message</param>
        public void UdpateStatusText(string Text)
        {
            if (InvokeRequired)
            {
                // We're not in the UI thread, so we need to call BeginInvoke
                BeginInvoke(new StringParameterDelegate(UdpateStatusText), new object[] { Text });
                return;
            }
            // Must be on the UI thread if we've got this far
            label1.ForeColor = Color.Black;
            label1.Text = Text;
        }


        /// <summary>
        /// Update text with message color defined as green/yellow/red/ for success/warning/failure
        /// </summary>
        /// <param name="Text">Message</param>
        /// <param name="tom">Type of Message</param>
        public void UdpateStatusTextWithStatus(string Text, TypeOfMessage tom)
        {
            if (InvokeRequired)
            {
                // We're not in the UI thread, so we need to call BeginInvoke
                BeginInvoke(new StringParameterWithStatusDelegate(UdpateStatusTextWithStatus), new object[] { Text, tom });
                return;
            }
            // Must be on the UI thread if we've got this far
            switch (tom)
            {
                case TypeOfMessage.Error:
                    label1.ForeColor = Color.Red;
                    break;
                case TypeOfMessage.Warning:
                    label1.ForeColor = Color.Yellow;
                    break;
                case TypeOfMessage.Success:
                    label1.ForeColor = Color.Green;
                    break;
            }
            label1.Text = Text;

        }

        /// <summary>
        /// Prevents the closing of form other than by calling the CloseSplashScreen function
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void SplashForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (CloseSplashScreenFlag == false)
                e.Cancel = true;
        }
    }
}

﻿
namespace SplashIt
{
    partial class SplashForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.browserControl = new System.Windows.Forms.WebBrowser();
            this.SuspendLayout();
            // 
            // browserControl
            // 
            this.browserControl.AllowNavigation = false;
            this.browserControl.AllowWebBrowserDrop = false;
            this.browserControl.Dock = System.Windows.Forms.DockStyle.Fill;
            this.browserControl.IsWebBrowserContextMenuEnabled = false;
            this.browserControl.Location = new System.Drawing.Point(0, 0);
            this.browserControl.MinimumSize = new System.Drawing.Size(20, 20);
            this.browserControl.Name = "browserControl";
            this.browserControl.ScriptErrorsSuppressed = true;
            this.browserControl.ScrollBarsEnabled = false;
            this.browserControl.Size = new System.Drawing.Size(800, 450);
            this.browserControl.TabIndex = 0;
            this.browserControl.WebBrowserShortcutsEnabled = false;
            // 
            // SplashForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(800, 450);
            this.Controls.Add(this.browserControl);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "SplashForm";
            this.ShowIcon = false;
            this.SizeGripStyle = System.Windows.Forms.SizeGripStyle.Hide;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.SplashForm_FormClosing);
            this.Load += new System.EventHandler(this.SplashForm_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.WebBrowser browserControl;
    }
}


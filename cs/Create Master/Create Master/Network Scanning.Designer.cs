namespace Create_Master {
    partial class Network_Scanning {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing) {
            if (disposing && (components != null)) {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent() {
            this.wbBrowser = new System.Windows.Forms.WebBrowser();
            this.SuspendLayout();
            // 
            // wbBrowser
            // 
            this.wbBrowser.Dock = System.Windows.Forms.DockStyle.Fill;
            this.wbBrowser.Location = new System.Drawing.Point(0, 0);
            this.wbBrowser.MinimumSize = new System.Drawing.Size(20, 20);
            this.wbBrowser.Name = "wbBrowser";
            this.wbBrowser.Size = new System.Drawing.Size(284, 264);
            this.wbBrowser.TabIndex = 0;
            this.wbBrowser.Url = new System.Uri("http://dlinkps-bd4df9/scan.html", System.UriKind.Absolute);
            this.wbBrowser.DocumentCompleted += new System.Windows.Forms.WebBrowserDocumentCompletedEventHandler(this.wbBrowser_DocumentCompleted);
            // 
            // Network_Scanning
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(284, 264);
            this.Controls.Add(this.wbBrowser);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "Network_Scanning";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.Text = "Scan Image";
            this.TopMost = true;
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.WebBrowser wbBrowser;
    }
}
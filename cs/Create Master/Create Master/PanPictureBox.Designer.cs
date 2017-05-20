namespace Create_Master {
    partial class PanPictureBox {
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

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent() {
            this._ImagePanel = new System.Windows.Forms.Panel();
            this._ImageBox = new System.Windows.Forms.PictureBox();
            this._ImagePanel.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this._ImageBox)).BeginInit();
            this.SuspendLayout();
            // 
            // _ImagePanel
            // 
            this._ImagePanel.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                            | System.Windows.Forms.AnchorStyles.Left)
                            | System.Windows.Forms.AnchorStyles.Right)));
            this._ImagePanel.AutoScroll = true;
            this._ImagePanel.Controls.Add(this._ImageBox);
            this._ImagePanel.Location = new System.Drawing.Point(3, 3);
            this._ImagePanel.Name = "_ImagePanel";
            this._ImagePanel.Size = new System.Drawing.Size(200, 200);
            this._ImagePanel.TabIndex = 3;
            // 
            // _ImageBox
            // 
            this._ImageBox.Location = new System.Drawing.Point(0, 0);
            this._ImageBox.Name = "_ImageBox";
            this._ImageBox.Size = new System.Drawing.Size(200, 200);
            this._ImageBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this._ImageBox.TabIndex = 0;
            this._ImageBox.TabStop = false;
            // 
            // PanPictureBox
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.Controls.Add(this._ImagePanel);
            this.Name = "PanPictureBox";
            this.Size = new System.Drawing.Size(206, 206);
            this.Enter += new System.EventHandler(this.PanPictureBox_Enter);
            this._ImagePanel.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this._ImageBox)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel _ImagePanel;
        private System.Windows.Forms.PictureBox _ImageBox;
    }
}

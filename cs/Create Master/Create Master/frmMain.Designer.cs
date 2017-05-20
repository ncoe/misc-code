namespace Create_Master
{
	partial class frmMain
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		// My Variables
		bool _saved = true;

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
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmMain));
			this._openDialog = new System.Windows.Forms.OpenFileDialog();
			this._saveDialog = new System.Windows.Forms.SaveFileDialog();
			this._mainMenu = new System.Windows.Forms.MenuStrip();
			this._menuFile = new System.Windows.Forms.ToolStripMenuItem();
			this._fileOpen = new System.Windows.Forms.ToolStripMenuItem();
			this._fileSave = new System.Windows.Forms.ToolStripMenuItem();
			this._fileScan = new System.Windows.Forms.ToolStripMenuItem();
			this._filePreview = new System.Windows.Forms.ToolStripMenuItem();
			this._filePrint = new System.Windows.Forms.ToolStripMenuItem();
			this.toolStripSeparator2 = new System.Windows.Forms.ToolStripSeparator();
			this._fileExit = new System.Windows.Forms.ToolStripMenuItem();
			this._EditImage = new System.Windows.Forms.Button();
			this._lblColor = new System.Windows.Forms.Label();
			this._myDocument = new System.Drawing.Printing.PrintDocument();
			this._printPreview = new System.Windows.Forms.PrintPreviewDialog();
			this._printDialog = new System.Windows.Forms.PrintDialog();
			this._Tolarance = new System.Windows.Forms.NumericUpDown();
			this._cmbxZoom = new System.Windows.Forms.ComboBox();
			this._lblZoom = new System.Windows.Forms.Label();
			this._picImage = new Create_Master.PanPictureBox();
			this._mainMenu.SuspendLayout();
			((System.ComponentModel.ISupportInitialize)(this._Tolarance)).BeginInit();
			this.SuspendLayout();
			// 
			// _openDialog
			// 
			this._openDialog.Filter = "All Images|*.jpg;*.jpeg;*.gif;*.bmp;*.png|JPEG Images (*.jpg,*.jpeg)|*.jpg;*.jpeg" +
				 "|Gif Images (*.gif)|*.gif|Bitmaps (*.bmp)|*.bmp|PNG Images (*.png)|*.png";
			// 
			// _saveDialog
			// 
			this._saveDialog.Filter = "JPEG Images (*.jpg,*.jpeg)|*.jpg;*.jpeg|Gif Images (*.gif)|*.gif|Bitmaps (*.bmp)|" +
				 "*.bmp|PNG Images (*.png)|*.png";
			// 
			// _mainMenu
			// 
			this._mainMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this._menuFile});
			this._mainMenu.Location = new System.Drawing.Point(0, 0);
			this._mainMenu.Name = "_mainMenu";
			this._mainMenu.Size = new System.Drawing.Size(592, 24);
			this._mainMenu.TabIndex = 0;
			this._mainMenu.Text = "Main Menu";
			// 
			// _menuFile
			// 
			this._menuFile.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this._fileOpen,
            this._fileSave,
            this._fileScan,
            this._filePreview,
            this._filePrint,
            this.toolStripSeparator2,
            this._fileExit});
			this._menuFile.Name = "_menuFile";
			this._menuFile.Size = new System.Drawing.Size(37, 20);
			this._menuFile.Text = "&File";
			// 
			// _fileOpen
			// 
			this._fileOpen.Image = ((System.Drawing.Image)(resources.GetObject("_fileOpen.Image")));
			this._fileOpen.ImageTransparentColor = System.Drawing.Color.Magenta;
			this._fileOpen.Name = "_fileOpen";
			this._fileOpen.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.O)));
			this._fileOpen.Size = new System.Drawing.Size(235, 22);
			this._fileOpen.Text = "&Open";
			this._fileOpen.Click += new System.EventHandler(this.fileOpen_Click);
			// 
			// _fileSave
			// 
			this._fileSave.Image = ((System.Drawing.Image)(resources.GetObject("_fileSave.Image")));
			this._fileSave.ImageTransparentColor = System.Drawing.Color.Magenta;
			this._fileSave.Name = "_fileSave";
			this._fileSave.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.S)));
			this._fileSave.Size = new System.Drawing.Size(235, 22);
			this._fileSave.Text = "&Save";
			this._fileSave.Click += new System.EventHandler(this.fileSave_Click);
			// 
			// _fileScan
			// 
			this._fileScan.Name = "_fileScan";
			this._fileScan.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.A)));
			this._fileScan.Size = new System.Drawing.Size(235, 22);
			this._fileScan.Text = "Aquire Network Image";
			this._fileScan.Click += new System.EventHandler(this._fileScan_Click);
			// 
			// _filePreview
			// 
			this._filePreview.Name = "_filePreview";
			this._filePreview.Size = new System.Drawing.Size(235, 22);
			this._filePreview.Text = "Print Preview";
			this._filePreview.Click += new System.EventHandler(this._filePreview_Click);
			// 
			// _filePrint
			// 
			this._filePrint.Image = global::Create_Master.Properties.Resources.print;
			this._filePrint.Name = "_filePrint";
			this._filePrint.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.P)));
			this._filePrint.Size = new System.Drawing.Size(235, 22);
			this._filePrint.Text = "Print";
			this._filePrint.Click += new System.EventHandler(this._filePrint_Click);
			// 
			// toolStripSeparator2
			// 
			this.toolStripSeparator2.Name = "toolStripSeparator2";
			this.toolStripSeparator2.Size = new System.Drawing.Size(232, 6);
			// 
			// _fileExit
			// 
			this._fileExit.Name = "_fileExit";
			this._fileExit.Size = new System.Drawing.Size(235, 22);
			this._fileExit.Text = "E&xit";
			this._fileExit.Click += new System.EventHandler(this.fileExit_Click);
			// 
			// _EditImage
			// 
			this._EditImage.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
			this._EditImage.Enabled = false;
			this._EditImage.Location = new System.Drawing.Point(12, 601);
			this._EditImage.Name = "_EditImage";
			this._EditImage.Size = new System.Drawing.Size(75, 23);
			this._EditImage.TabIndex = 3;
			this._EditImage.Text = "Edit Image";
			this._EditImage.UseVisualStyleBackColor = true;
			this._EditImage.Click += new System.EventHandler(this._EditImage_Click);
			// 
			// _lblColor
			// 
			this._lblColor.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this._lblColor.BackColor = System.Drawing.Color.Black;
			this._lblColor.ForeColor = System.Drawing.Color.White;
			this._lblColor.Location = new System.Drawing.Point(415, 598);
			this._lblColor.Name = "_lblColor";
			this._lblColor.Size = new System.Drawing.Size(165, 28);
			this._lblColor.TabIndex = 2;
			this._lblColor.Text = "No Image";
			this._lblColor.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
			this._lblColor.Visible = false;
			// 
			// _myDocument
			// 
			this._myDocument.PrintPage += new System.Drawing.Printing.PrintPageEventHandler(this._myDocument_PrintPage);
			// 
			// _printPreview
			// 
			this._printPreview.AutoScrollMargin = new System.Drawing.Size(0, 0);
			this._printPreview.AutoScrollMinSize = new System.Drawing.Size(0, 0);
			this._printPreview.ClientSize = new System.Drawing.Size(400, 300);
			this._printPreview.Document = this._myDocument;
			this._printPreview.Enabled = true;
			this._printPreview.Icon = ((System.Drawing.Icon)(resources.GetObject("_printPreview.Icon")));
			this._printPreview.Name = "_printPreview";
			this._printPreview.Visible = false;
			// 
			// _printDialog
			// 
			this._printDialog.Document = this._myDocument;
			this._printDialog.UseEXDialog = true;
			// 
			// _Tolarance
			// 
			this._Tolarance.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this._Tolarance.DecimalPlaces = 1;
			this._Tolarance.Increment = new decimal(new int[] {
            1,
            0,
            0,
            65536});
			this._Tolarance.Location = new System.Drawing.Point(353, 601);
			this._Tolarance.Maximum = new decimal(new int[] {
            500,
            0,
            0,
            0});
			this._Tolarance.Name = "_Tolarance";
			this._Tolarance.Size = new System.Drawing.Size(56, 20);
			this._Tolarance.TabIndex = 4;
			this._Tolarance.Value = new decimal(new int[] {
            65,
            0,
            0,
            0});
			this._Tolarance.Visible = false;
			// 
			// _cmbxZoom
			// 
			this._cmbxZoom.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this._cmbxZoom.FormattingEnabled = true;
			this._cmbxZoom.Items.AddRange(new object[] {
            "300%",
            "250%",
            "200%",
            "150%",
            "100%",
            "90%",
            "80%",
            "70%",
            "60%",
            "50%",
            "40%",
            "30%",
            "20%",
            "10%"});
			this._cmbxZoom.Location = new System.Drawing.Point(226, 603);
			this._cmbxZoom.Name = "_cmbxZoom";
			this._cmbxZoom.Size = new System.Drawing.Size(121, 21);
			this._cmbxZoom.TabIndex = 5;
			this._cmbxZoom.SelectedIndexChanged += new System.EventHandler(this._cmbxZoom_SelectedIndexChanged);
			// 
			// _lblZoom
			// 
			this._lblZoom.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this._lblZoom.AutoSize = true;
			this._lblZoom.Location = new System.Drawing.Point(186, 608);
			this._lblZoom.Name = "_lblZoom";
			this._lblZoom.Size = new System.Drawing.Size(34, 13);
			this._lblZoom.TabIndex = 6;
			this._lblZoom.Text = "Zoom";
			// 
			// _picImage
			// 
			this._picImage.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
							| System.Windows.Forms.AnchorStyles.Left)
							| System.Windows.Forms.AnchorStyles.Right)));
			this._picImage.BackColor = System.Drawing.SystemColors.Control;
			this._picImage.Image = null;
			this._picImage.Location = new System.Drawing.Point(12, 27);
			this._picImage.Name = "_picImage";
			this._picImage.Size = new System.Drawing.Size(568, 568);
			this._picImage.TabIndex = 1;
			this._picImage.Zoom = 1D;
			this._picImage.MouseEnter += new System.EventHandler(this._picImage_MouseEnter);
			// 
			// frmMain
			// 
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
			this.ClientSize = new System.Drawing.Size(592, 634);
			this.Controls.Add(this._lblZoom);
			this.Controls.Add(this._cmbxZoom);
			this.Controls.Add(this._picImage);
			this.Controls.Add(this._Tolarance);
			this.Controls.Add(this._lblColor);
			this.Controls.Add(this._EditImage);
			this.Controls.Add(this._mainMenu);
			this.Location = new System.Drawing.Point(30, 10);
			this.MainMenuStrip = this._mainMenu;
			this.Name = "frmMain";
			this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
			this.Text = "Create Master";
			this._mainMenu.ResumeLayout(false);
			this._mainMenu.PerformLayout();
			((System.ComponentModel.ISupportInitialize)(this._Tolarance)).EndInit();
			this.ResumeLayout(false);
			this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.OpenFileDialog _openDialog;
        private System.Windows.Forms.SaveFileDialog _saveDialog;
		private System.Windows.Forms.MenuStrip _mainMenu;
		private System.Windows.Forms.ToolStripMenuItem _menuFile;
		private System.Windows.Forms.ToolStripMenuItem _fileOpen;
		private System.Windows.Forms.ToolStripMenuItem _fileSave;
		private System.Windows.Forms.ToolStripSeparator toolStripSeparator2;
		private System.Windows.Forms.ToolStripMenuItem _fileExit;
		private System.Windows.Forms.Button _EditImage;
		private System.Windows.Forms.Label _lblColor;
		private System.Drawing.Printing.PrintDocument _myDocument;
		private System.Windows.Forms.PrintPreviewDialog _printPreview;
		private System.Windows.Forms.ToolStripMenuItem _filePreview;
		private System.Windows.Forms.PrintDialog _printDialog;
        private System.Windows.Forms.NumericUpDown _Tolarance;
        private System.Windows.Forms.ToolStripMenuItem _filePrint;
        private PanPictureBox _picImage;
        private System.Windows.Forms.ComboBox _cmbxZoom;
		  private System.Windows.Forms.ToolStripMenuItem _fileScan;
		  private System.Windows.Forms.Label _lblZoom;
	}
}


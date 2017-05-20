using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Forms;

namespace Create_Master {
    public partial class frmMain : Form {
        public Image _myImage = null;

        public frmMain() {
            InitializeComponent();

            _lblColor.BackColor = Color.FromArgb(30, 30, 30);
            if (System.Environment.GetCommandLineArgs().Length == 2) {
                string FileName = System.Environment.GetCommandLineArgs()[1];
                if (FileName.EndsWith(".bmp", StringComparison.CurrentCultureIgnoreCase) ||
                    FileName.EndsWith(".gif", StringComparison.CurrentCultureIgnoreCase) ||
                    FileName.EndsWith(".jpg", StringComparison.CurrentCultureIgnoreCase) ||
                    FileName.EndsWith(".jpeg", StringComparison.CurrentCultureIgnoreCase) ||
                    FileName.EndsWith(".png", StringComparison.CurrentCultureIgnoreCase) ||
                    FileName.EndsWith(".tiff", StringComparison.CurrentCultureIgnoreCase)) {
                    _myImage = Image.FromFile(FileName);
                    _openDialog.FileName = FileName;
                    _picImage.Image = _myImage;
                    _EditImage.Enabled = true;
                }
            }

            _openDialog.InitialDirectory = Environment.SpecialFolder.MyDocuments.ToString();
            _saveDialog.InitialDirectory = Environment.SpecialFolder.MyDocuments.ToString();
            _cmbxZoom.SelectedIndex = _cmbxZoom.Items.IndexOf("100%");
        }

        private void fileOpen_Click(object sender, EventArgs e) {
            if (DialogResult.OK == _openDialog.ShowDialog()) {
                try {
                    string _sFileName = _openDialog.FileName;
                    _myImage = Image.FromFile(_openDialog.FileName);
                    _picImage.Image = _myImage;
                    _lblColor.Text = "Ready";
                    _EditImage.Enabled = true;
                } catch (Exception ex) {
                    MessageBox.Show(ex.Message);
                }
            }
        }

        private void fileSave_Click(object sender, EventArgs e) {
            if (null != _picImage.Image) {
                try {
                    string _sFileName = _openDialog.FileName;
                    _sFileName = _sFileName.Substring(0, _sFileName.LastIndexOf('.'));
                    _saveDialog.FileName = _sFileName;
                    if (DialogResult.OK == _saveDialog.ShowDialog()) {
                        _sFileName = _saveDialog.FileName;
                        if (_sFileName.EndsWith(".bmp", StringComparison.CurrentCultureIgnoreCase)) {
                            _myImage.Save(_sFileName, ImageFormat.Bmp);
                        } else if (_sFileName.EndsWith(".gif", StringComparison.CurrentCultureIgnoreCase)) {
                            _myImage.Save(_sFileName, ImageFormat.Gif);
                        } else if (_sFileName.EndsWith(".jpg", StringComparison.CurrentCultureIgnoreCase)) {
                            _myImage.Save(_sFileName, ImageFormat.Jpeg);
                        } else if (_sFileName.EndsWith(".jpeg", StringComparison.CurrentCultureIgnoreCase)) {
                            _myImage.Save(_sFileName, ImageFormat.Jpeg);
                        } else if (_sFileName.EndsWith(".png", StringComparison.CurrentCultureIgnoreCase)) {
                            _myImage.Save(_sFileName, ImageFormat.Png);
                        } else if (_sFileName.EndsWith(".tiff", StringComparison.CurrentCultureIgnoreCase)) {
                            _myImage.Save(_sFileName, ImageFormat.Tiff);
                        }
                        _saved = true;
                    }
                } catch (Exception ex) {
                    MessageBox.Show(ex.Message);
                }
            }
        }

        private void fileExit_Click(object sender, EventArgs e) {
            if (!_saved) {
                if (DialogResult.Yes == MessageBox.Show("Would you like to save your file?", "Save File",
                                          MessageBoxButtons.YesNo, MessageBoxIcon.Question, MessageBoxDefaultButton.Button1)) {
                    _fileSave.PerformClick();
                }
            }

            Application.Exit();
        }

        private void _EditImage_Click(object sender, EventArgs e) {
            Auto_Threshold();
            //Threshold();
        }

        private void Threshold() {
            long avgRed = 0;
            long avgGreen = 0;
            long avgBlue = 0;
            int count = 0;
            double chisquare = 0;
            double _Percent;
            double _Tol = (double)_Tolarance.Value;
            _saved = false;
            _EditImage.Enabled = false;
            Cursor.Current = Cursors.WaitCursor;

            if (null != _myImage) {
                Bitmap buffer = new Bitmap(_myImage);
                Color pixColor;
                count = buffer.Height * buffer.Width;

                _lblColor.Text = "Mean";
                _lblColor.Refresh();
                // Calculate Average Color
                for (int yPix = 0; yPix < buffer.Height; yPix++) {
                    for (int xPix = 0; xPix < buffer.Width; xPix++) {
                        pixColor = buffer.GetPixel(xPix, yPix);
                        avgRed = avgRed + pixColor.R;
                        avgGreen = avgGreen + pixColor.G;
                        avgBlue = avgBlue + pixColor.B;
                    }
                }
                avgRed = avgRed / count;
                avgGreen = avgGreen / count;
                avgBlue = avgBlue / count;
                _lblColor.BackColor = Color.FromArgb((int)avgRed, (int)avgGreen, (int)avgBlue);
                _lblColor.ForeColor = Color.FromArgb(255 - (int)avgRed, 255 - (int)avgGreen, 255 - (int)avgBlue);

                _lblColor.Text = "Editing...";
                _lblColor.Refresh();
                // Manipulate the image
                for (int yPix = 0; yPix < buffer.Height; yPix++) {
                    for (int xPix = 0; xPix < buffer.Width; xPix++) {
                        pixColor = buffer.GetPixel(xPix, yPix);

                        chisquare = (pixColor.R - avgRed) * (pixColor.R - avgRed) / avgRed;
                        chisquare += (pixColor.G - avgGreen) * (pixColor.G - avgGreen) / avgGreen;
                        chisquare += (pixColor.B - avgBlue) * (pixColor.B - avgBlue) / avgBlue;

                        if (chisquare > _Tol) {
                            pixColor = Color.FromArgb(0, 0, 0);
                        } else {
                            pixColor = Color.FromArgb(255, 255, 255);
                        }

                        buffer.SetPixel(xPix, yPix, pixColor);
                    }
                    if (yPix % 10 == 0) {
                        _Percent = ((double)yPix / buffer.Height);
                        _lblColor.Text = _Percent.ToString("p2");
                        _lblColor.Refresh();
                        if (yPix % 100 == 0) {
                            _picImage.Image = buffer;
                            _picImage.Refresh();
                        }
                    }

                    _myImage = buffer;
                    _picImage.Image = _myImage;
                }
                _lblColor.Text = "Done";
            }

            _EditImage.Enabled = true;
            Cursor.Current = Cursors.Default;
        }

        private void Auto_Threshold() {
            long avgRed = 0;
            long avgGreen = 0;
            long avgBlue = 0;
            int count = 0;
            double chisquareavg = 0;
            double chisquareback = 0;
            _saved = false;
            _EditImage.Enabled = false;
            Cursor.Current = Cursors.WaitCursor;

            if (null != _myImage) {
                string _sFileName = _openDialog.FileName;
                _myImage = Image.FromFile(_sFileName);
                _picImage.Image = _myImage;

                Bitmap buffer = new Bitmap(_myImage);
                Color pixColor;
                count = 0;

                // Calculate Average Color
                for (int yPix = 0; yPix < buffer.Height; yPix = yPix + 2) {
                    for (int xPix = 0; xPix < buffer.Width; xPix = xPix + 2) {
                        pixColor = buffer.GetPixel(xPix, yPix);
                        avgRed = avgRed + pixColor.R;
                        avgGreen = avgGreen + pixColor.G;
                        avgBlue = avgBlue + pixColor.B;
                    }
                }

                count = buffer.Height * buffer.Width >> 2;
                avgRed = avgRed / count;
                avgGreen = avgGreen / count;
                avgBlue = avgBlue / count;

                // Manipulate the image
                for (int yPix = 0; yPix < buffer.Height; ++yPix) {
                    for (int xPix = 0; xPix < buffer.Width; ++xPix) {
                        pixColor = buffer.GetPixel(xPix, yPix);

                        chisquareavg = (pixColor.R - avgRed) * (pixColor.R - avgRed) / avgRed;
                        chisquareavg += (pixColor.G - avgGreen) * (pixColor.G - avgGreen) / avgGreen;
                        chisquareavg += (pixColor.B - avgBlue) * (pixColor.B - avgBlue) / avgBlue;

                        chisquareback = pixColor.R * pixColor.R / avgRed;
                        chisquareback += pixColor.G * pixColor.G / avgGreen;
                        chisquareback += pixColor.B * pixColor.B / avgBlue;

                        if (chisquareavg < chisquareback)
                            pixColor = Color.White;
                        else
                            pixColor = Color.Black;

                        buffer.SetPixel(xPix, yPix, pixColor);
                    }

                    if (yPix % 100 == 0) {
                        _picImage.Image = buffer;
                        _picImage.Refresh();
                    }

                    _picImage.Image = buffer;
                }
                _myImage = buffer;
                _picImage.Image = _myImage;
            }

            _EditImage.Enabled = true;
            Cursor.Current = Cursors.Default;
        }

        private void _myDocument_PrintPage(object sender, System.Drawing.Printing.PrintPageEventArgs e) {
            Graphics gr = e.Graphics;
            float width = _myImage.Width;
            float height = _myImage.Height;

            if ((height / width) <= (1.0f * e.PageBounds.Height / e.PageBounds.Width)) {
                height = height / width;
                width = e.PageBounds.Width;
                height = height * width;
                gr.DrawImage(_myImage, e.PageBounds.X + (e.PageBounds.Width - width) / 2,
                     e.PageBounds.Y + (e.PageBounds.Height - height) / 2, width, height);
            } else {
                width = width / height;
                height = e.PageBounds.Height;
                width = height * width;
                gr.DrawImage(_myImage, e.PageBounds.X + (e.PageBounds.Width - width) / 2,
                     e.PageBounds.Y + (e.PageBounds.Height - height) / 2, width, height);
            }
        }

        private void _filePreview_Click(object sender, EventArgs e) {
            _printPreview.ShowDialog();
        }

        private void _filePrint_Click(object sender, EventArgs e) {
            if (_printDialog.ShowDialog() == DialogResult.OK) {
                _myDocument.Print();
            }
        }

        private void _cmbxZoom_SelectedIndexChanged(object sender, EventArgs e) {
            double _newZoom = Convert.ToDouble(_cmbxZoom.Text.Trim('%'));
            _newZoom /= 100.0;
            _picImage.Zoom = _newZoom;
        }

        private void _picImage_MouseEnter(object sender, EventArgs e) {
            _picImage.Focus();
        }

        private void _fileScan_Click(object sender, EventArgs e) {
            Network_Scanning myDialog = new Network_Scanning();
            myDialog.Show();
        }
    }
}
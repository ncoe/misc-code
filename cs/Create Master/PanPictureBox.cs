using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Text;
using System.Windows.Forms;

namespace Create_Master
{
    public partial class PanPictureBox : UserControl
    {
        private double _Zoom = 1.0;

        public PanPictureBox()
        {
            InitializeComponent();
        }

        [Browsable(true), Description("The Image to Display.")]
        public Image Image
        {
            get
            {
                return _ImageBox.Image;
            }
            set
            {
                _ImageBox.Image = value;

					 if (null != _ImageBox.Image)
					 {
						 _ImageBox.Width = Convert.ToInt32(_ImageBox.Image.Width * _Zoom);
						 _ImageBox.Height = Convert.ToInt32(_ImageBox.Image.Height * _Zoom);
					 }
				}
        }

        [Browsable(true), Description("Current Zoom")]
        public double Zoom
        {
            get
            {
                return _Zoom;
            }
            set
            {
                _Zoom = value;

                if (null != _ImageBox.Image)
                {
                    _ImageBox.Width = Convert.ToInt32(_ImageBox.Image.Width * _Zoom);
                    _ImageBox.Height = Convert.ToInt32(_ImageBox.Image.Height * _Zoom);
                }
            }
        }

		  private void PanPictureBox_Enter(object sender, EventArgs e)
		  {
			  _ImagePanel.Focus();
		  }
    }
}

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Net;
using mshtml;

namespace Create_Master
{
	public partial class Network_Scanning : Form
	{
		private int calls = 0;

		public Network_Scanning()
		{
			InitializeComponent();
		}

		private void wbBrowser_DocumentCompleted(object sender, WebBrowserDocumentCompletedEventArgs e)
		{
			calls++;
			this.Text = calls.ToString();

			HtmlDocument myDoc = null;
			myDoc = wbBrowser.Document;

			myDoc.All["scan_quality2"].InvokeMember("click");

			myDoc.All["scan_area_custom"].InvokeMember("click");
			myDoc.All["scan_area1"].InvokeMember("click");

			//myDoc.All["scan_start"].InvokeMember("click");
		}
	}
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Import necessary functions from user32.dll for window dragging
Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class User32 {
        [DllImport("user32.dll")]
        public static extern bool ReleaseCapture();
        
        [DllImport("user32.dll")]
        public static extern IntPtr SendMessage(IntPtr hWnd, int Msg, int wParam, int lParam);
    }
"@

# Constants for window dragging
$WM_NCLBUTTONDOWN = 0xA1
$HTCAPTION = 0x2

$IconBase64 = "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"
$IconBytes = [Convert]::FromBase64String($IconBase64)
$ims = New-Object IO.MemoryStream($IconBytes, 0, $IconBytes.Length)
$ims.Write($IconBytes, 0, $IconBytes.Length)

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Get-Wizard"
$form.Size = New-Object System.Drawing.Size(148, 178)
$form.Icon = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $ims).GetHIcon())
$form.TopMost = $true
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'None'  # Remove the border
$form.BackColor = [System.Drawing.Color]::Magenta  # Set the form's background color
$form.TransparencyKey = $form.BackColor  # Make the background color transparent

# Create PictureBox to hold the GIF
$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.SizeMode = "StretchImage"
$pictureBox.Dock = "None"  # Disable docking to use specific Size
$pictureBox.Size = New-Object System.Drawing.Size(128, 128)
$pictureBox.BackColor = [System.Drawing.Color]::Transparent

# Base64 encoded GIF (Placeholder)
$base64String = "R0lGODlhgACAANU/AK2PYv6MjP7WjGGVkpNoR8DAwP6M/tWM/ov+/v5r9mTT07FtoGSmbv5rta6EgYz+jK9vz2Sf04u1/v5ra1lLS1JLc1k/ZLG1g1M9OlhHMMd6emTTgcZ607FtbXd+lXR2asezelllS5xlLkghAA4YFn6Th2tSO5Zpem5iWLGD08dgmVdaXHtfh/nn97SA4I1SURwuMZN1o3xGZzNORv+Gw5WD0zFZczFzczFzS8dgzcdgYI9DAICAgK6urgAAAP///yH/C05FVFNDQVBFMi4wAwEAAAAh/wtYTVAgRGF0YVhNUDw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYwIDYxLjEzNDc3NywgMjAxMC8wMi8xMi0xNzozMjowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpGNzdGMTE3NDA3MjA2ODExQjY5OURCQ0JGRDQyNjUzMSIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDo1MEM3RjJBRURGNUExMUU1ODYxN0I0MzAzQ0ZERUE5NyIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDo1MEM3RjJBRERGNUExMUU1ODYxN0I0MzAzQ0ZERUE5NyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ1M1IE1hY2ludG9zaCI+IDx4bXBNTTpEZXJpdmVkRnJv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"

# Convert the Base64 string back to a byte array
$imageBytes = [Convert]::FromBase64String($base64String)

# Create a memory stream and load the image
$memoryStream = New-Object System.IO.MemoryStream(, $imageBytes)
$loadedImage = [System.Drawing.Image]::FromStream($memoryStream)

$pictureBox.Image = $loadedImage

# Add PictureBox to the form
$form.Controls.Add($pictureBox)

# Add MouseDown event to the PictureBox to enable dragging
$pictureBox.Add_MouseDown({
        [User32]::ReleaseCapture() | Out-Null
        [User32]::SendMessage($form.Handle, $WM_NCLBUTTONDOWN, $HTCAPTION, 0) | Out-Null
    })

# Add MouseClick event to close the form on right-click
$pictureBox.Add_MouseClick({
        param($sender, $e)
        if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Right) {
            $form.Close()
        }
    })

# Show the Form
$form.ShowDialog()
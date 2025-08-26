Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Get-FileTypeFromBase64 {
    param (
        [string]$Base64String
    )
    # Decode the Base64 string to byte array
    $FileBytes = [Convert]::FromBase64String($Base64String)

    # Get the file signature (first few bytes)
    $FileSignature = -join ($FileBytes[0..3] | ForEach-Object { $_.ToString("X2") })
    $FileType = switch ($FileSignature) {
        '89504E47' {
            'png' 
        }   # PNG
        'FFD8FFE0' {
            'jpg' 
        }   # JPEG
        'FFD8FFE1' {
            'jpg' 
        }   # JPEG
        'FFD8FFE2' {
            'jpg' 
        }   # JPEG
        '47494638' {
            'gif' 
        }   # GIF
        '25504446' {
            'pdf' 
        }   # PDF
        '504B0304' {
            'zip' 
        }   # ZIP
        '4D5A' {
            'exe' 
        }   # EXE (MZ header)
        default {
            'unknown' 
        }
    }
    return $FileType, $FileBytes
}

function Save-FileFromBase64 {
    param (
        [string]$Base64String,
        [string]$OutputDirectory
    )
    $result = Get-FileTypeFromBase64 -Base64String $Base64String
    $FileType = $result[0]
    $FileBytes = $result[1]

    if ($FileType -eq 'unknown') {
        Write-Output "Unknown file type. Cannot save the file."
        return
    }
    $FileName = [System.IO.Path]::Combine($OutputDirectory, [System.Guid]::NewGuid().ToString() + ".$FileType")
    [System.IO.File]::WriteAllBytes($FileName, $FileBytes)
}

function Base64 {
    $Base64_Code = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$Files"))
    Set-Clipboard -Value $Base64_Code
    [System.Windows.Forms.MessageBox]::Show("Base64 sent to clipboard.", "Base64 --> Clipboard", 'OK', 'Information')
}

function Get-Error {
    [System.Windows.Forms.MessageBox]::Show("$($Error[0].Exception.Message)", 'ERROR', 'OK', 'ERROR')
}

$IconBase64 = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAEG0lEQVRoQ9WZTWgTQRTH5yVpI21B8AOttKBSQRRqYgTRg+i19GqhNC14KnjWU0EEsQfBowe92UTBeBTrTQ8eRAptEKQHLQpGK0Kh4EfZtpvx7SYbdzfzPVutc0qyM+/9fzNv3rydANmiRks5CuNVCJtn/WbrPuLA1lgw3hPqfQ4D0LuFLtLl/oz/buszcYBAfBvAzGA3gdSPpuBfCNdtK973kYSRSJjMDmRh6L1DKQEA4q9EvCHkTQSYSsJ34gBJiNKxkRgALRcuE+reSTrGZTCJAITjPnAYz0CtDV7OfcfA6vG/L1XTcJ3UZSJFz60BWOJ5ELSc+4ri98UF8WBVwKwAROJZoaQDqyLeOgslCYA5ax6KCwVV4a1V1h3QiuVS7ht+3iuMz9BJTB8WjhLXXVTtr6rLOIRksx8PIVrOfyGU9oqFpaZhfF7rfFAGoDP5UwToXLDhtAGa5YVsZnU3tDpArL7BjFLHjCIcH6mF/iUAq77B4qwDi7N11ZhGG7ew79V/sgK8MlgYRlgHQbGaCguWhh1jjBRY1kH03CvYiBdKjMaKZRmAyfuD0h6g5dN9hDqffJ3ZIxkYeey20mmlsJM47mqEIbuRhZG3beGF++YJ7pth3qSwAFgHYni8FIAzazV01m+yerxV4Im3AsAZc3DGOplCUx15GJurGkJ4q9nnjwV4iSfwOZYd+qhwgay7z0WpVbgCujFrAmM7hgtAKxfTxHm3KXOge/AIk0LbWQGLML5wTJiqeQ9pKb9MCN0vA8Dn9xBiUqEftwstD2KSSDWSRHtbR/tZ7sbnA+Q28FlGRZjtKtiEKj+EyrkPuIEPqgBgn2WEOKDYN9JNJr6x0ckrPBTPsuxbbeKwQZNVQPEO2mBnuZhanv1EAEzEe/qUZr8JsoUAsISZYkA3fDBJnEAE1XNkDQG6tENIYZbqaDgdNkwrZ3YRZ20l5qytn4LtPyZ29+6AoWdeuLU1aSkhcqRbsLWVCy/OZ0ht1ct2wmZ8EkdmNnbI6Ir3bdF6D0y88S94g0Yf5CdInd4XESQCIJsl1ZDggHslOTMaZAlCKYQUxc9jv7ysL/fGjvXKCXAbC70rwtWROVR9rpwSY+8Tcfu0dHKSZNKzMDrHKy0iQxJZAWXxTdeysFCdNK+fNYCu+IY4WMGzY4+OUF5fKwAz8YGU1BReYk3bQhgBoHDvesS7JrFrGTIMo9WnNka0AexmnSEVsv1QfF0zhdACQPEldFQ0dcaN49jfsTr2dQGYf9rpOEwaYtsAkE1yCC5VP+pOxvYBSMENGFu49t8CmB5ueitQOd5JnA5mXa47c/H+fwXAc6ryv4ABzGcEaNzUaTatFQhsYzrllr+a/v3uprPvjzVxGAKJplUgNbz+YF764sot4TXN4bA/G+GBnd/2jblAobJvMgAAAABJRU5ErkJggg=="
$IconBytes = [Convert]::FromBase64String($IconBase64)
$ims = New-Object IO.MemoryStream($IconBytes, 0, $IconBytes.Length)
$ims.Write($IconBytes, 0, $IconBytes.Length)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Base64 Converter (.jpg, .gif, .png, .exe, .zip)"
$form.Size = New-Object System.Drawing.Size(290, 150)
$form.Icon = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $ims).GetHIcon())
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"

$dropPanel = New-Object System.Windows.Forms.Panel
$dropPanel.Location = New-Object System.Drawing.Point(10, 10)
$dropPanel.Size = New-Object System.Drawing.Size(257, 50)
$dropPanel.BackColor = [System.Drawing.Color]::LightGray
$dropPanel.AllowDrop = $true
$dropPanel.BorderStyle = 'FixedSingle'
$dropPanelText = New-Object System.Windows.Forms.Label
$dropPanelText.Text = "Drag and Drop File Here"
$dropPanelText.AutoSize = $true
$dropPanelText.Location = New-Object System.Drawing.Point(70, 20)
$dropPanel.Controls.Add($dropPanelText)
$form.Controls.Add($dropPanel)

$dropPanel.Add_DragEnter({
        param ($sender, $e)
        if ($e.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
            $e.Effect = [System.Windows.Forms.DragDropEffects]::Copy
        }
    })

$dropPanel.Add_DragDrop({
        param ($sender, $e)
        $files = $e.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
        if ($files.Length -gt 0) {
            try {
                Base64
            }
            catch {
                Get-Error
            }
        }
    })

$frombase64Button = New-Object System.Windows.Forms.Button
$frombase64Button.Text = "From: Base64"
$frombase64Button.Location = New-Object System.Drawing.Point(90, 70)
$frombase64Button.Size = New-Object System.Drawing.Size(100, 30)
$form.Controls.Add($frombase64Button)

$frombase64Button.Add_Click({
        try {
            $base64String = Get-Clipboard
            $outputDirectory = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
            Save-FileFromBase64 -Base64String $base64String -OutputDirectory $outputDirectory
            [System.Windows.Forms.MessageBox]::Show("Your file has been saved here:`n`n$outputDirectory", "Clipboard --> Base64", 'OK', 'Information')
        }
        catch {
            Get-Error
        }
    })

$Help_Image = New-Object System.Windows.Forms.Label
$IconBase64 = 'iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAAxklEQVRIS8WW0Q2AIAxEZTz/HcKRHMJ/x9NAgkGE3h0Y9JfS1zsK1U3ENy/rWQs79s2hFGaAlTxPbMGKECU5A3tBegARmKt6QL4AlEA3BAFKnrN7KIh1qEznBQgTaLUp2i9B0mSpOghBvjKXEOVwKGA4pNYAqFBJSUsbeye6IEhBtLoZwgJkJX6Dt0wBBAi6jGhWoHVflAxRldwQVg17y/OXmHogS883cy6xqLHzJFbLVMgcdhrzz4xPK1BUyX8ruR1oXiD7LvmhkjZLp5jjAAAAAElFTkSuQmCC'
$IconBytes = [Convert]::FromBase64String($IconBase64)
$Stream = [System.IO.MemoryStream]::new($IconBytes, 0, $IconBytes.Length)
$Custom_Bookmark_Help_Picture = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($Stream).GetHIcon()))
$ResizedImage = $Custom_Bookmark_Help_Picture.ToBitmap().GetThumbnailImage(20, 20, $null, [System.IntPtr]::Zero)
$Help_Image.Image = $ResizedImage
$Help_Image.Size = New-Object System.Drawing.Size(20, 20)
$Help_Image.Location = New-Object System.Drawing.Point(60, 77)
$Help_Image.BringToFront()
$form.Controls.Add($Help_Image)

$Help_Image.Add_Click({
        [System.Windows.Forms.MessageBox]::Show("Copy the Base64 code into your clipboard then click the `"From: Base64`" button.`nThe file will then be saved into your downloads folder.", "Help", 'OK', 'Information')
    })

# Make PowerShell Disappear
$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
$asyncwindow = Add-Type -MemberDefinition $windowcode -Name Win32ShowWindowAsync -Namespace Win32Functions -PassThru
$null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
 
# Force garbage collection just to start slightly lower RAM usage.
[void][System.GC]::Collect()

$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
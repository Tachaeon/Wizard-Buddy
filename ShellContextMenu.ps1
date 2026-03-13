function Show-ShellContextMenu {
    param (
        [Parameter(Mandatory)]
        [string]$FilePath,
        [System.Drawing.Point]$Position = [System.Windows.Forms.Cursor]::Position
    )

    if (-not (Test-Path $FilePath)) {
        Write-Warning "File not found: $FilePath"
        return
    }

    $resolvedPath = (Resolve-Path $FilePath).Path
    $folderPath = [System.IO.Path]::GetDirectoryName($resolvedPath)
    $fileName = [System.IO.Path]::GetFileName($resolvedPath)

    $shell = New-Object -ComObject Shell.Application
    $folder = $shell.NameSpace($folderPath)
    if (-not $folder) {
        Write-Warning "Could not open folder: $folderPath"
        return
    }

    $item = $folder.ParseName($fileName)
    if (-not $item) {
        Write-Warning "Could not find item: $fileName"
        return
    }

    $verbs = $item.Verbs()
    if ($verbs.Count -eq 0) {
        return
    }

    $menu = New-Object System.Windows.Forms.ContextMenuStrip
    $menu.RenderMode = [System.Windows.Forms.ToolStripRenderMode]::System

    foreach ($verb in $verbs) {
        if ([string]::IsNullOrEmpty($verb.Name)) {
            $menu.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator)) | Out-Null
        }
        else {
            $menuItem = $menu.Items.Add($verb.Name)
            $menuItem.Tag = $verb
            $menuItem.add_Click({
                param($sender, $e)
                $sender.Tag.DoIt()
            })
        }
    }

    # Remove leading/trailing separators
    while ($menu.Items.Count -gt 0 -and $menu.Items[0] -is [System.Windows.Forms.ToolStripSeparator]) {
        $menu.Items.RemoveAt(0)
    }
    while ($menu.Items.Count -gt 0 -and $menu.Items[$menu.Items.Count - 1] -is [System.Windows.Forms.ToolStripSeparator]) {
        $menu.Items.RemoveAt($menu.Items.Count - 1)
    }

    if ($menu.Items.Count -gt 0) {
        $menu.Show($Position)
    }
}

function Register-ShellContextMenuHandler {
    param (
        [Parameter(Mandatory)]
        [System.Windows.Forms.ToolStripMenuItem]$MenuItem,
        [Parameter(Mandatory)]
        [string]$FilePath
    )

    $MenuItem.Tag = $FilePath
    $MenuItem.add_MouseDown({
        param($sender, $e)
        if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Right) {
            $filePath = $sender.Tag
            if ($filePath -and (Test-Path $filePath)) {
                Show-ShellContextMenu -FilePath $filePath -Position ([System.Windows.Forms.Cursor]::Position)
            }
        }
    })
}

param([string]$Source, [string]$Target, [int]$Width, [int]$Height, [switch]$Launcher)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
function Resize-Asset([string]$Src, [string]$Dst, [int]$W, [int]$H) {
    $inputImage = [System.Drawing.Image]::FromFile($Src)
    $bitmap = [System.Drawing.Bitmap]::new($W, $H)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.Clear([System.Drawing.Color]::FromArgb(7,7,12))
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($inputImage, 0, 0, $W, $H)
        $bitmap.Save($Dst, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally { $graphics.Dispose(); $bitmap.Dispose(); $inputImage.Dispose() }
}
Resize-Asset $Source $Target $Width $Height
if ($Launcher) {
    $res = Join-Path $PSScriptRoot '../../android/app/src/main/res'
    foreach ($entry in @{mdpi=48;hdpi=72;xhdpi=96;xxhdpi=144;xxxhdpi=192}.GetEnumerator()) {
        $dir = Join-Path $res ('mipmap-' + $entry.Key)
        Resize-Asset $Source (Join-Path $dir 'ic_launcher.png') $entry.Value $entry.Value
        $fg = [int]($entry.Value * 108 / 48)
        Resize-Asset $Source (Join-Path $dir 'ic_launcher_foreground.png') $fg $fg
    }
}

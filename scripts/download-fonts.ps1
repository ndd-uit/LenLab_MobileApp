$ErrorActionPreference = 'Stop'
$fontTarget = Join-Path $PSScriptRoot '../packages/lenlab_shared/assets/fonts'
New-Item -ItemType Directory -Force -Path $fontTarget | Out-Null
$fontFiles = @{
 'BeVietnamPro-Regular.ttf' = 'bevietnampro/BeVietnamPro-Regular.ttf'
 'BeVietnamPro-SemiBold.ttf' = 'bevietnampro/BeVietnamPro-SemiBold.ttf'
 'BeVietnamPro-Bold.ttf' = 'bevietnampro/BeVietnamPro-Bold.ttf'
 'PlayfairDisplay.ttf' = 'playfairdisplay/PlayfairDisplay%5Bwght%5D.ttf'
 'Inter.ttf' = 'inter/Inter%5Bopsz,wght%5D.ttf'
 'Bangers.ttf' = 'bangers/Bangers-Regular.ttf'
 'Cousine-Bold.ttf' = 'cousine/Cousine-Bold.ttf'
 'Cousine-OFL.txt' = 'cousine/OFL.txt'
 'BeVietnamPro-OFL.txt' = 'bevietnampro/OFL.txt'
 'PlayfairDisplay-OFL.txt' = 'playfairdisplay/OFL.txt'
 'Inter-OFL.txt' = 'inter/OFL.txt'
 'Bangers-OFL.txt' = 'bangers/OFL.txt'
}
foreach ($fontName in $fontFiles.Keys) {
  & curl.exe -f -L -s --retry 2 -o (Join-Path $fontTarget $fontName) ('https://raw.githubusercontent.com/google/fonts/main/ofl/' + $fontFiles[$fontName])
  if ($LASTEXITCODE -ne 0) { throw "Download failed: $fontName" }
}
Write-Output 'Fonts and licenses downloaded.'

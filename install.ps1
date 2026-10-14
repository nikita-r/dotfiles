
<# copying to "Code/User" #>

if (Get-Variable IsMacOS -ea:0 -ValueOnly) {

$dirCode = "$env:HOME/Library/Application Support/Code"
#$dirExt = "$env:HOME/.vscode/extensions"

New-Item $dirCode/User -Type Dir -ea:0 | Out-Null

Write-Host $dirCode/User/keybindings.json
$json = Get-Content ./vscode/keybindings.json
$flagE = 0
$json -split "`n" |% {
  if ($_ -match '"ctrl\+shift\+e"') {
      if (!$flagE++) { return $_ }
  }
  if ($_ -match '"ctrl(\+shift)?\+space"') { return $_ }
  if ($_ -match '"ctrl\+shift\+a"') { return }
  if ($_ -match '"ctrl\+shift\+f"') { return $_ }
  if ($_ -match '"command": ""') { return $_ }
  if ($_ -match '"key": "ctrl(\+shift)?\+\\\\"(?!, //)') { return $_ }
  if ($_ -match '"key": "ctrl\+j"') { return $_ }
  if ($_ -match '"ctrl\+alt\+[carx]"') { return $_ }
  if ($_ -match '"command": "-[^"]+"') { return $_ }
  if ($_ -match '"command": "noop"') {
    #if ($_ -match '"ctrl\+shift\+[un]"') { return }
  } else {
    if ($_ -match '"ctrl\+alt\+(up|down|\\\\)"') { return $_ }
  }
  $_ `
    -iReplace '"key": "(c)trl\+(shift\+)?([^+"]+)(?<!\+[vcq`g])"', '"key": "$2$1md+$3"' `
    -iReplace '"key": "(shift)\+(c)trl\+([^+"]+)"', '"key": "$2md+$1+$3"' `
    -iReplace '"key": "(c)trl\+(alt)\+([^+"]+)"', '"key": "$2+$1md+$3"' `
    -iReplace '"key": "(c)trl\+(shift)\+(alt)\+([^+"]+)"', '"key": "$2+$3+$1md+$4"' `
    -iReplace '"key": "ctrl\+k ctrl\+([^"]+\+)?([^"]+)"', '"key": "cmd+k $1cmd+$2"' `
    -iReplace '"key": "ctrl\+k ([^"]+)"', '"key": "cmd+k $1"' `
} | Out-File $dirCode/User/keybindings.json

Write-Host $dirCode/User/settings.json
Copy-Item ./vscode/settings.json $dirCode/User/settings.json

} else {

$dirCode = "$env:AppData\Code"
#$dirExt = "$env:UserProfile\.vscode\extensions"

New-Item $dirCode\User -Type Dir -ea:0 | Out-Null

'keybindings.json', 'settings.json' |% {
  Copy-Item .\vscode\$_ $dirCode\User\$_ -PassThru |% FullName
}

}


<# `code --install-extension` #>

Write-Host; Write-Host $ code --install-extension

Get-Item ./vscode-vsix/*.vsix |% FullName |% {
  Write-Host (Split-Path $_ -Leaf)
  if (Get-Variable IsWindows -ea:0 -ValueOnly) {
    cmd.exe /c ('code --install-extension "' + $_ + '" --force 2>&1')
  } else {
    /bin/sh -c ('code --install-extension "' + $_ + '" --force 2>&1')
  }
}

Get-Content ./vscode/extensions.txt |% Trim |? { $_ } |? { $_ -notLike '#*' } |% {
  Write-Host $_
  if (Get-Variable dirExt -ea:0 -ValueOnly) {
    code --install-extension $_ --user-data-dir $dirCode --extensions-dir $dirExt
  } else {
    code --install-extension $_
  }
}


<# Fonts #>

if (Get-Variable IsMacOS -ea:0 -ValueOnly) {
  $dirFontsDst = Join-Path $env:HOME 'Library/Fonts'
  $hkcuKey = $null
} elseif (Get-Variable IsWindows -ea:0 -ValueOnly) {
  $dirFontsDst = Join-Path $env:LocalAppData 'Microsoft\Windows\Fonts'
  $hkcuKey = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
} else {
  $dirFontsDst = $null
}

if ($dirFontsDst) {
  foreach ($zip in (Get-ChildItem ./fnt/ -File -Filter *.zip)) {
    Write-Host; Write-Host Installing TTF from $zip.Name

    $dirZipExtract = Join-Path ([io.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $dirZipExtract | Out-Null

    try {
      Expand-Archive -LiteralPath $zip.FullName -DestinationPath $dirZipExtract -Force

      Get-ChildItem -LiteralPath $dirZipExtract -File -Filter *.ttf |% {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $dirFontsDst $_.Name) -Force

        if ($hkcuKey) {
          $hkcuName = '{0} (TrueType)' -f ([io.Path]::GetFileNameWithoutExtension($_.Name))
          Set-ItemProperty -Path $hkcuKey -Name ($hkcuName-cReplace'^([A-Z][a-z]+)([A-Z][a-z]+)\S+','$1 $2') -Value (Join-Path $dirFontsDst $_.Name)
        }
      }
    } finally {
      Remove-Item -LiteralPath $dirZipExtract -Recurse -Force -ea:0
    }
  }
}


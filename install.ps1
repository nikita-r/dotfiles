
<# copying to User #>
if (Get-Variable IsMacOS -ea:0 -ValueOnly) {

$dirCode = "$env:HOME/Library/Application Support/Code"
#$dirExt = "$env:HOME/.vscode/extensions"

New-Item $dirCode/User -Type Dir -ea:0 | Out-Null

$filename = 'keybindings.json'
$json = Get-Content ./vscode/$filename
$json -split "`n" |% {
  if ($_ -match '"ctrl\+(shift\+)?space"') { return $_ }
  if ($_ -match '"ctrl\+shift\+a"') { return }
  if ($_ -match '"command": ""') { return $_ }
  if ($_ -match '"key": "ctrl\+[ij]"') { return $_ }
  if ($_ -match '"ctrl\+alt\+[anpr]"') { return $_ }
  if ($_ -match '"command": "-[^"]+"') { return $_ }
  if ($_ -match '"command": "noop"') {
    #if ($_ -match '"ctrl\+shift\+[un]"') { return }
  } else {
    if ($_ -match '"ctrl\+alt\+(up|down|\\\\)"') { return $_ }
  }
  $_ `
    -iReplace '"key": "(c)trl\+(shift\+)?([^+"]+)(?<!\+[q`g])"', '"key": "$2$1md+$3"' `
    -iReplace '"key": "(shift)\+(c)trl\+([^+"]+)"', '"key": "$2md+$1+$3"' `
    -iReplace '"key": "(c)trl\+(alt)\+([^+"]+)"', '"key": "$2+$1md+$3"' `
    -iReplace '"key": "(c)trl\+(shift)\+(alt)\+([^+"]+)"', '"key": "$2+$3+$1md+$4"' `
    -iReplace '"key": "ctrl\+k ctrl\+([^"]+\+)?([^"]+)"', '"key": "cmd+k $1cmd+$2"' `
    -iReplace '"key": "ctrl\+k ([^"]+)"', '"key": "cmd+k $1"' `
} | Out-File $dirCode/User/$filename

$filename = 'settings.json'
Copy-Item ./vscode/$filename $dirCode/User/$filename

} else {

$dirCode = "$env:AppData\Code"
#$dirExt = "$env:UserProfile\.vscode\extensions"

New-Item $dirCode\User -Type Dir -ea:0 | Out-Null

'keybindings.json', 'settings.json' |% {
  Copy-Item .\vscode\$_ $dirCode\User\$_
}

}


$urlRaw = 'https://raw.githubusercontent.com/nikita-r/dotfiles/master'
$tmp = New-TemporaryFile
$tmp = Rename-Item $tmp ($tmp.FullName + '.vsix') -PassThru
'ctf0.macros-0.0.4', 'my.feather-vscode-1.0.17',
'alefragnani.Bookmarks-13.5.66', 'alefragnani.numbered-bookmarks-8.4.66',
'ryu1kn.text-marker-1.11.0', 'Tyriar.sort-lines-1.11.0' |% {
  Write-Host "$_.vsix"
  Invoke-WebRequest $urlRaw/vscode-vsix/"$_.vsix" -OutFile $tmp
  if (Get-Variable IsWindows -ea:0 -ValueOnly) {
    cmd.exe /c ('code --install-extension "' + $tmp.FullName + '" --force 2>&1')
  } else {
    /bin/sh -c ('code --install-extension "' + $tmp.FullName + '" --force 2>&1')
  }
}
Remove-Item $tmp


-split((
  iwr -UseBasicParsing $urlRaw/vscode/extensions.txt
).Content) |% Trim |? { $_ } |? { $_ -notLike '#*' } |% {
  if (Get-Variable dirExt -ea:0 -ValueOnly) {
    code --install-extension $_ --user-data-dir $dirCode --extensions-dir $dirExt
  } else {
    code --install-extension $_
  }
}

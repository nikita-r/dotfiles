
$urlRaw = 'https://raw.githubusercontent.com/nikita-r/dotfiles/master'


if (Get-Variable IsMacOS -ea:0 -ValueOnly) {

$dirUsr = "$env:HOME/Library/Application Support/Code"
#$dirExt = "$env:HOME/.vscode/extensions"

New-Item $dirUsr/User -Type Dir -ea:0 | Out-Null

$urlPath = "$urlRaw/vscode"

# 'settings.json'
Invoke-WebRequest $urlPath/settings.json -OutFile $dirUsr/User/settings.json

# 'keybindings.json'
$json = Invoke-WebRequest -UseBasicParsing $urlPath/keybindings.json
$json -split '`n' `
  -iReplace '"key": "(c)trl\+(shift\+)?([^+"]+)"', '"key": "$2$1md+$3"' `
  -iReplace '"key": "(shift)\+(c)trl\+([^+"]+)"', '"key": "$2md+$1+$3"' `
  -iReplace '"key": "(c)trl\+(alt)\+([^+"]+)"', '"key": "$2+$1md+$3"' `
  -iReplace '"key": "(c)trl\+(shift)\+(alt)\+(\w+)"', '"key": "$2+$3+$1md+$4"' `
  -iReplace '"key": "ctrl\+k ctrl\+(.+\+)?([^"]+)"', '"key": "cmd+k $1cmd+$2"' `
  -iReplace '"key": "ctrl\+k ([^"]+)"', '"key": "cmd+k $1"' `
  | Out-File $dirUsr/User/keybindings.json

} else {

$dirUsr = "$env:AppData\Code"
#$dirExt = "$env:UserProfile\.vscode\extensions"

New-Item $dirUsr\User -Type Dir -ea:0 | Out-Null

'keybindings.json', 'settings.json' |% {
  iwr $urlRaw/vscode/$_ -OutFile $dirUsr\User\$_
}

}


-split((
  iwr -UseBasicParsing $urlRaw/vscode/extensions.txt
).Content) |% Trim |? { $_ } |? { $_ -notLike '#*' } |% {
  if (Get-Variable dirExt -ea:0 -ValueOnly) {
    code --install-extension $_ --user-data-dir $dirUsr --extensions-dir $dirExt
  } else {
    code --install-extension $_
  }
}



New-Item $env:AppData\Code\User -Type Dir -ea:0 | Out-Null

'keybindings.json', 'settings.json' |% {
  iwr https://raw.githubusercontent.com/nikita-r/dotfiles/master/vscode/$_ -OutFile $env:AppData\Code\User\$_
}


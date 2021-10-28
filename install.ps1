
New-Item $env:AppData\Code\User -Type Dir -ea:0 | Out-Null

$urlDotCode = 'https://raw.githubusercontent.com/nikita-r/dotfiles/master/vscode'

'keybindings.json', 'settings.json' |% {
  iwr $urlDotCode/$_ -OutFile $env:AppData\Code\User\$_
}

-split((iwr $urlDotCode/extensions.txt).Content) |? { $_ -notLike '#*' } |% {
  code --install-extension $_
}


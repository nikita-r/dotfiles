
$dirUsr = "$env:AppData\Code"
#$dirExt = "$env:UserProfile\.vscode\extensions"

New-Item $dirUsr\User -Type Dir -ea:0 | Out-Null

$urlRepoMain = 'https://raw.githubusercontent.com/nikita-r/dotfiles/master'

'keybindings.json', 'settings.json' |% {
  iwr $urlRepoMain/vscode/$_ -OutFile $dirUsr\User\$_
}

-split((
  iwr $urlRepoMain/vscode/extensions.txt
).Content) |% Trim |? { $_ } |? { $_ -notLike '#*' } |% {
  if (Get-Variable dirExt -ea:0 -ValueOnly) {
    code --install-extension $_ --user-data-dir $dirUsr --extensions-dir $dirExt
  } else {
    code --install-extension $_
  }
}


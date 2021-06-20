
function ResolveTo-AbsolutePath {
  [CmdletBinding()] param (
[Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
[string[]]$Path
  )
process {
  $Path |% { $PSCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($_) }
} }

function Test-Elevated {
    $wid = [Security.Principal.WindowsIdentity]::GetCurrent()
    $prp = New-Object Security.Principal.WindowsPrincipal $wid
    $adm = [Security.Principal.WindowsBuiltInRole]::Administrator
    $prp.IsInRole($adm)
}

function DeepCopy-Object ($obj) {
    $memStr = [io.MemoryStream]::new()
    $fmtBin = [Runtime.Serialization.Formatters.Binary.BinaryFormatter]::new()
    $fmtBin.Serialize($memStr, $obj)
    $memStr.Position=0
    $fmtBin.Deserialize($memStr)
}


function Reload-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'User') `
      + ';' + [Environment]::GetEnvironmentVariable('Path', 'Machine')
}

function ReplaceWith-SymbolicLink ($AbsPath, $target) {
  if (-not (Test-Path -Path (Split-Path $AbsPath) -Type Container)) {
    New-Item -ItemType Directory -Path (Split-Path $AbsPath)
  }
  if (Test-Path -Path $AbsPath) {
    Remove-Item -Path $AbsPath
  }
  New-Item -ItemType SymbolicLink -Path $AbsPath -Value $target
}


function Install-App ($url, $OutFile, $Arguments) {
  if (Test-Path -Path "$OutFile.skip") {
    return
  }
# if (Test-Path -Path $OutFile) {
#   Remove-Item -Path $OutFile
# }
  if (-not (Test-Path -Path $OutFile)) {
    $ProgressPreference, $tmp = "SilentlyContinue", $ProgressPreference
    Invoke-WebRequest -Uri $url -OutFile $OutFile
    $ProgressPreference = $tmp
  }
  if ($Arguments.Count) {
    $Process = Start-Process -FilePath $OutFile -Wait -PassThru -ArgumentList $Arguments
  } else {
    $Process = Start-Process -FilePath $OutFile -Wait -PassThru
  }
  if ($Process.ExitCode) {
    Write-Error "`"${OutFile}`" installation has failed.  ExitCode=${Process.ExitCode}"
    return
  }
  Set-Content -Path "$OutFile.skip" -Value 'skip'
}

function Install-App-7z {
  Install-App https://www.7-zip.org/a/7z1900-x64.exe `
              -OutFile setup-7z.exe -Arguments @('/S')
}

function Install-App-Insomnia {
  Install-App https://updates.insomnia.rest/downloads/windows/latest `
              -OutFile setup-insomnia.exe -Arguments @('--silent')
}

function Install-App-VSCode {
  Install-App https://aka.ms/win32-x64-user-stable `
              -OutFile setup-vscode.exe -Arguments @(
                "/SP-"
                "/SILENT"
                "/SUPPRESSMSGBOXES"
                "/TASKS=""addcontextmenufiles,addcontextmenufolders,addtopath"""
                "/LOG=""setup-vscode.log"""
              )
}

function Configure-App-VSCode {
  ReplaceWith-SymbolicLink "$home\AppData\Roaming\Code\User\keybindings.json" `
                      -Target "${MyDotfiles}\vscode\keybindings.json"
# ReplaceWith-SymbolicLink "$home\AppData\Roaming\Code\User\settings.json" `
#                     -Target "${MyDotfiles}\vscode\settings.json"
  Copy-Item -LiteralPath "${MyDotfiles}\vscode\settings.json" `
            -Destination "$home\AppData\Roaming\Code\User\settings.json" `
            #-Force -Confirm:$false
  Get-Content "${MyDotfiles}\vscode\extensions.txt" |% { code --install-extension $_ }
}



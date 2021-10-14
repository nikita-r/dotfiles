
function Get-ScriptDirectory {
  Split-Path ($(
    if ($host.Name -clike '* ISE Host') {
      $global:psISE.CurrentFile.FullPath
    } else {
      $global:PSCommandPath
    }
  ))
}


function Test-Elevated {
    $wid = [Security.Principal.WindowsIdentity]::GetCurrent()
    $prp = New-Object Security.Principal.WindowsPrincipal $wid
    $adm = [Security.Principal.WindowsBuiltInRole]::Administrator
    $prp.IsInRole($adm)
}

function Parse-UrlQuery-FromClipboard {
    $url=Get-Clipboard; Write-Host $url
    $q = $url.Substring($url.IndexOf('?')+1).Split('&')
    $q = $q |% { if ('=' -in $_.ToCharArray()) { $_ } else { "$_=" } } | ConvertFrom-StringData
    $q |% { foreach ($key in $($_.Keys)) { $_[$key] = [Net.WebUtility]::UrlDecode($_[$key]) } }
    $q | Out-GridView -PassThru
}

function View-ProcUtil {
  [CmdletBinding()] param (
[Parameter(Mandatory=$true)]
[ValidatePattern('^\w[-\w\s\.][-\w\s\.]+$')]
[string]$ProcNamePrefix
  )
  process {
    Get-WmiObject Win32_PerfRawData_PerfProc_Process -Filter "Name like '$ProcNamePrefix%'" | sort IDProcess `
    | select @{N='CreatPID';E={$_.CreatingProcessID}}, @{N='PID';E={'{0,9:d}' -f $_.IDProcess}}, Name `
    , @{N='ElapsedHours';E={'{0,12:n3}' -f ( ($_.Timestamp_Object - $_.ElapsedTime) / $_.Frequency_Object / 3600 )}} `
    , @{N='PercentProcT';E={'{0,12:p2}' -f ( $_.PercentProcessorTime / ($_.Timestamp_Object - $_.ElapsedTime) )}} `
    | ft
  }
}


<# WScript.Shell #>

function Toggle-Mute { (New-Object -com WScript.Shell).SendKeys([char]173) }

function Set-SpeakersVolume ([float]$v) {
    $wsh = New-Object -com WScript.Shell
    1..50 |% { $wsh.SendKeys([char]174) }
    $v /= 2 # in case of ([int]$v), would round half to even
    for ($i=0; $i -lt $v; ++$i) {
        $wsh.SendKeys([char]175) # incr by 2pp
    }
}


<# WiP: set apps up #>

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
    Write-Error ("`"${OutFile}`" installation has failed.  ExitCode=" + $Process.ExitCode)
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



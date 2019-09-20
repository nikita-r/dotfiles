#·profile.ps1

#. "$(join-path (split-path $profile -Parent) 'LocalFunctions.ps1')"

# > powershell.exe –NoProfile –File %script%
$ErrorActionPreference = 'Stop'; Set-StrictMode -Version Latest

function prompt {
  $strUser = "[$env:UserName]"
  $strTime = Get-Date -F 'MM\/dd|HH:mm'
  Write-Host "$strTime$strUser>" -N
  return ' '
}

function ccd ($dir) { try {
	mkdir $dir |% FullName
	if ($?) { Set-Location $dir }
} catch {'{0}' -f $_.Exception} }

del alias:pwd
function  pwd  { (Get-Location).Path }  # != [System.Environment]::CurrentDirectory

rm alias:dir
function dir {
  gci @Args |% {
    (rvpa -LiteralPath $_.FullName -Relative) `
    + $(switch ($_.Mode[0]) {
          'd' {'\'} '-' {''}
          default { '?' }
        })
  } | sort
}

$PSDefaultParameterValues += @{'Get-Help:ShowWindow' = $true}

<# misc utility funcs #>

function Test-Elevated {
    $wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp = New-Object System.Security.Principal.WindowsPrincipal($wid)
    $adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    $prp.IsInRole($adm)
}

function Get-EnumValues {
  param([string]$enum)
  [enum]::GetValues([type]$enum) |% {
    $rslt = [ordered]@{}
  } {
    $rslt.add($_, $_.value__)
  } {
    $rslt
  }
}

function View-UrlParams-FromClipboard {
    $url = Get-Clipboard; write $url
    Add-Type -AssemblyName System.Web
    $q = $url.Substring($url.IndexOf('?')+1).Split('&') | ConvertFrom-StringData
    $q |% { foreach ($key in $($_.Keys)) { $_[$key] = [System.Web.HttpUtility]::UrlDecode($_[$key]) } }
    $q | Out-GridView
}

# > CertUtil -EncodeHex -f $FilePath (New-TemporaryFile | tee -Variable tmp).FullName
function View-FileHexed { [CmdletBinding()]
    param([string]$FilePath, [int]$HeadCount = 240)
    gc -Encoding Byte -TotalCount $HeadCount (gi -LiteralPath $FilePath) `
    |% { Write-Host ('{0:x}' -f $_).PadLeft(2, '0') -n '' }
}

function View-ProcUtil {
  param([Parameter(Mandatory=$true)][ValidateLength(3, 33)][string]$ProcNamePrefix)
  process {
    Get-WmiObject Win32_PerfRawData_PerfProc_Process -Filter "Name like '$ProcNamePrefix%'" | sort IDProcess `
    | select @{N='CreatPID';E={$_.CreatingProcessID}}, @{N='PID';E={'{0,9:d}' -f $_.IDProcess}}, Name `
    , @{N='ElapsedHours';E={'{0,12:n3}' -f ( ($_.Timestamp_Object - $_.ElapsedTime) / $_.Frequency_Object / 3600 )}} `
    , @{N='PercentProcT';E={'{0,12:p2}' -f ( $_.PercentProcessorTime / ($_.Timestamp_Object - $_.ElapsedTime) )}} `
    | ft
  }
}


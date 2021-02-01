#·profile.ps1

#. "$(join-path (split-path $profile) '???.ps1')"

# > powershell.exe -NoProfile -File %script%
$ErrorActionPreference='Stop'
Set-StrictMode -Version:Latest # Set-StrictMode -Off

function prompt { "$(Get-Date -f 'MM\/dd|HH:mm')[$(if($PSVersionTable['Platform']-ceq'Unix'){((&tty)-replace'^/dev/')+'|'+$env:USER}else{$env:UserName})]> " }
$PSDefaultParameterValues += @{'Get-Help:ShowWindow' = $true}

function ccd ($dir) { try {
	mkdir $dir |% FullName
	if ($?) { Set-Location $dir }
} catch {'{0}' -f $_.Exception} }


<# for dir nav #>

del alias:pwd
function  pwd  { (Get-Location).Path }  # != [System.Environment]::CurrentDirectory

del alias:dir
function  dir  {
  gci -Force @args |% {
    (rvpa -LiteralPath $_.FullName -Relative) `
    + $(switch ($_.Mode[0]) {
          'd' {'\'} '-' {''}
          default { '?' }
        })
  } | sort
}

function swapd {
if ((Get-Location -Stack).Count -eq 0) { throw }
$a=Get-Location; popd; $b=Get-Location
Set-Location $a; pushd $b
"swapd to `"$b`""
}


# HISTIGNORE
Set-PSReadLineOption -AddToHistoryHandler { param ($cmd)
    if ($cmd -like ' *') { return $false }
    if ($cmd.Length -le 3) { return $false }
    return $true
}


<# string manipulation helpers #>

# Natural Sort: ... | sort $_naturally
$_naturally = { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(10, '0') }) }

function normalize-space([string]$str) { # like XPath
    if ([string]::IsNullOrWhiteSpace($str)) { return '' }
    $str -replace '^\s+' -replace '\s+$' -replace '\s+', ' '
}


<# misc utility funcs #>

function Is-Numeric ($x) {
  try {
    0 + $x | Out-Null
    return ![string]::IsNullOrWhiteSpace($x) # this line would handle [DBNull]::Value correctly (were it to reach it) # irrealis
  } catch {
    return $false
  }
}

function Test-Elevated {
    $wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp = New-Object System.Security.Principal.WindowsPrincipal($wid)
    $adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    $prp.IsInRole($adm)
}

function Get-EnumValues ($enum) {
  [enum]::GetValues($enum) |% {
    $rslt = [ordered]@{}
  } {
    $rslt.add($_, $_.value__)
  } {
    $rslt
  }
}

function View-UrlParams-FromClipboard {
    $url = Get-Clipboard
    write $url
    $q = $url.Substring($url.IndexOf('?')+1).Split('&') | ConvertFrom-StringData
    $q |% { foreach ($key in $($_.Keys)) { $_[$key] = [Net.WebUtility]::UrlDecode($_[$key]) } }
    $q | Out-GridView
}

# > CertUtil -EncodeHex -f $FilePath (New-TemporaryFile | tee -Variable tmp).FullName
function View-FileHexed { [CmdletBinding()]
    param([string]$FilePath, [int]$HeadCount = 240)
    gc -Encoding Byte -TotalCount $HeadCount (gi -LiteralPath $FilePath) `
    |% { Write-Host (' {0:x2}' -f $_) -n }
    Write-Host
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

function DeepCopy-Object ($obj) {
    $memStr = [io.MemoryStream]::new()
    $fmtBin = [Runtime.Serialization.Formatters.Binary.BinaryFormatter]::new()
    $fmtBin.Serialize($memStr, $obj)
    $memStr.Position=0
    $fmtBin.Deserialize($memStr)
}

function Get-Timestamp {
    $datetime = (Get-Date).ToUniversalTime()
    (Get-Date $datetime -f s) + (Get-Date $datetime -F.fffZ)
}

function Get-LoremIpsum { “Lorem ipsum dolor sit amet, consectetur adipiscing elit.  Nam hendrerit nisi sed sollicitudin pellentesque.  Nunc posuere purus rhoncus pulvinar aliquam.  Ut aliquet tristique nisl vitae volutpat.  Nulla aliquet porttitor venenatis.  Donec a dui et dui fringilla consectetur id nec massa.  Aliquam erat volutpat.  Sed ut dui ut lacus dictum fermentum vel tincidunt neque.  Sed sed lacinia lectus.  Duis sit amet sodales felis.  Duis nunc eros, mattis at dui ac, convallis semper risus.  In adipiscing ultrices tellus, in suscipit massa vehicula eu.” }



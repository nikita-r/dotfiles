#·profile.ps1

#. "$(join-path (split-path $profile) '???.ps1')"

# > powershell.exe -NoProfile -File %script%
$ErrorActionPreference='Stop' # Inquire
Set-StrictMode -Version:Latest # Set-StrictMode -Off

function prompt { "$(Get-Date -f 'MM\/dd|HH:mm')[$(if($PSVersionTable['Platform']-ceq'Unix'){((&tty)-replace'^/dev/')+'|'+$env:USER}else{$env:UserName})]> " }
$PSDefaultParameterValues += @{'Get-Help:ShowWindow'=$true}

function ccd ($dir) { try {
	mkdir $dir |% FullName
	if ($?) { Set-Location $dir }
} catch {'{0}' -f $_.Exception} }


<# for dir nav #>

del alias:pwd
function  pwd  { (Get-Location).Path }  # != [System.Environment]::CurrentDirectory

function ResolveTo-AbsolutePath {
  [CmdletBinding()] param (
[Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
[string[]]$Path
  )

  $Path |% { $PSCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($_) }
}

del alias:dir
function  dir  {
  $pwd=$( pwd ).TrimEnd('\')
  $regex = [regex] ('^' + [regex]::Escape($pwd) + '\\' + '(?!$)')
  gci -Force @args |% {
    ( $_.FullName -replace $regex, '.\' ) `
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
Write-Host "swapd to `"$b`""
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
    0 + $x | Out-Null # [DBNull|NullString]::Value throw here; [string]::Empty|[AutomationNull]::Value do not
    return ![string]::IsNullOrWhiteSpace($x)
  } catch {
    return $false
  }
}

function Test-Elevated {
    $wid = [Security.Principal.WindowsIdentity]::GetCurrent()
    $prp = New-Object Security.Principal.WindowsPrincipal $wid
    $adm = [Security.Principal.WindowsBuiltInRole]::Administrator
    $prp.IsInRole($adm)
}

function Get-EnumValues ([string]$enum) { # cannot be of type [type] here
    $enum = [type]( $enum -replace '^\[([^][]+)\]$', '$1' )
    $rslt = [ordered]@{}
    [enum]::GetValues($enum) |% { $rslt.add($_, $_.value__) }
    $rslt
}

function Parse-UrlQuery-FromClipboard {
    $url=Get-Clipboard; Write-Host $url
    $q = $url.Substring($url.IndexOf('?')+1).Split('&')
    $q = $q |% { if ('=' -in $_.ToCharArray()) { $_ } else { "$_=" } } | ConvertFrom-StringData
    $q |% { foreach ($key in $($_.Keys)) { $_[$key] = [Net.WebUtility]::UrlDecode($_[$key]) } }
    $q | Out-GridView -PassThru
}

# > CertUtil -EncodeHex -f $FilePath (New-TemporaryFile | tee -Variable tmp).FullName
function View-FileHexed {
    [CmdletBinding()] param (
[Parameter(Mandatory=$true)][string]$FilePath
, [int]$HeadCount=20
)
    $i = Get-Item -Force -LiteralPath $FilePath
    $a = Get-Content -Encoding Byte -TotalCount $HeadCount `
            $i |% { ' {0:x2}' -f $_ }
    -join($a)
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



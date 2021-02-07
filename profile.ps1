#·profile.ps1

# guard against repeated load of the profile
if ($PSDefaultParameterValues.Contains('Get-Help:ShowWindow')) { throw }
$PSDefaultParameterValues += @{'Get-Help:ShowWindow'=$true}

$ErrorActionPreference='Stop' # Inquire
Set-StrictMode -Version:Latest # Set-StrictMode -Off

#. "$(join-path (split-path $profile) 'profile.extra-func.ps1')"

function prompt { (Get-Date -f 'MM\/dd|HH:mm') `
                + "[$(if($PSVersionTable['Platform']-ceq'Unix'){((&tty)-replace'^/dev/')+'|'+$env:USER}else{$env:UserName})]" `
                + '>' * (1+$NestedPromptLevel) + ' ' `
                }

# HISTIGNORE
Set-PSReadLineOption -HistoryNoDuplicates:$true
Set-PSReadLineOption -AddToHistoryHandler { param ($cmd)
    if ($cmd -like ' *') { return $false }
    if ($cmd.Length -le 3) { return $false }
    if ($cmd -in 'exit', 'Parse-UrlQuery-FromClipboard') { return $false }
    if ($cmd -like 'gcm *' -or $cmd -like 'shcm *') { return $false }
    if ($cmd -like 'View-*') { return $false }
    return $true
}


<# dir nav #>

function ccd ($dir) { try {
	mkdir $dir |% FullName
	if ($?) { Set-Location $dir }
} catch {'{0}' -f $_.Exception} }

del alias:pwd
function  pwd  { (Get-Location).Path }  # != [System.Environment]::CurrentDirectory

del alias:dir
function  dir  {
  $pwd=$( pwd )#.TrimEnd([IO.Path]::DirectorySeparatorChar)
  $regex = [regex] ('^' + [regex]::Escape($(Join-Path $pwd $null)) + '(?!$)')
  gci -Force @args |% {
    ( $_.FullName -replace $regex, (Join-Path . $null) ) `
    + $(switch ($_.Mode[0]) {
          'd' { [IO.Path]::DirectorySeparatorChar }
          '-' { $null }
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


<# string manipulation helpers #>

# Natural Sort: ... | sort $_naturally
$_naturally = { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(10, '0') }) }

function normalize-space([string]$str) { # like XPath
    if ([string]::IsNullOrWhiteSpace($str)) { return '' }
    $str -replace '^\s+' -replace '\s+$' -replace '\s+', ' '
}


<# misc utility #>

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

function Get-Timestamp {
    $datetime = (Get-Date).ToUniversalTime()
    (Get-Date $datetime -f s) + (Get-Date $datetime -F.fffZ)
}

function Get-LoremIpsum { “Lorem ipsum dolor sit amet, consectetur adipiscing elit.  Nam hendrerit nisi sed sollicitudin pellentesque.  Nunc posuere purus rhoncus pulvinar aliquam.  Ut aliquet tristique nisl vitae volutpat.  Nulla aliquet porttitor venenatis.  Donec a dui et dui fringilla consectetur id nec massa.  Aliquam erat volutpat.  Sed ut dui ut lacus dictum fermentum vel tincidunt neque.  Sed sed lacinia lectus.  Duis sit amet sodales felis.  Duis nunc eros, mattis at dui ac, convallis semper risus.  In adipiscing ultrices tellus, in suscipit massa vehicula eu.” }


<# web dev helpers #>

function Get-AuthHeader-Basic ([string]${client_id}, [string]${client_secret}) {
    if (${client_id} -match ':') { throw }
    $str = "${client_id}:${client_secret}"
    if ($str -cmatch '[^\x20-\x7E]') { throw }
    return @{Authorization="Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($str)))"}
}

function Format-Json {
#[CmdletBinding()] param ()
#if ($PSCmdlet.MyInvocation.PipelinePosition -eq 1) { throw }
$input | ConvertFrom-Json | ConvertTo-Json @args
}

Set-Alias fj Format-Json



#·profile.ps1
#> notepad (Join-Path (Split-Path $PROFILE) profile.ps1)

# guard against repeated load of the profile
if ($PSDefaultParameterValues.Contains('Get-Help:ShowWindow')) { throw }
$PSDefaultParameterValues += @{'Get-Help:ShowWindow'=$true}

$ErrorActionPreference='Stop' # Inquire
Set-StrictMode -Version:Latest # Set-StrictMode -Off

if ($PSVersionTable['Platform'] -ceq 'Unix') {
  $prompt_intern = "[$((&tty)-replace'^/dev/')|$env:USER]"
} else {
  $prompt_intern = '[' + [Environment]::UserName + ']'
  try{ . (Join-Path (Split-Path $PROFILE) profile-win-extra-func.ps1) }catch{}
}
if ([Environment]::Is64BitProcess -ne [Environment]::Is64BitOperatingSystem) {
  $prompt_intern += $(
    switch ([IntPtr]::Size) {
                4 { '(x86)' }
                8 { '(x64)' }
          default { '(?)' }
    }
  )
}
function prompt { (Get-Date -f 'MM\/dd|HH:mm') `
                + $prompt_intern `
                + '>' * (1+$NestedPromptLevel) + ' ' `
                }

# HISTIGNORE
Set-PSReadLineOption -HistoryNoDuplicates:$true
Set-PSReadLineOption -AddToHistoryHandler { param ($cmd)
    if ($cmd -like ' *') { return $false }
    if ($cmd.Length -le 3) { return $false }
    if ($cmd -in 'exit'<#, ''#>) { return $false }
    return $true
}


<# dir nav #>

function ccd ($dir) { try {
	mkdir $dir |% FullName
	if ($?) { Set-Location $dir }
} catch {'{0}' -f $_.Exception} }

del alias:pwd
function  pwd  { (Get-Location).Path }  # != [Environment]::CurrentDirectory

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


<# Predicates #>

function Are-ArraysEqual ([Object[]]$A, [Object[]]$B, [switch]$StrictOrdering) {
  if ($StrictOrdering) {
    !@( Compare-Object -SyncWindow:0 $A $B )
  } else {
    !@( Compare-Object -SyncWindow:0 ($A | Sort-Object) ($B | Sort-Object) )
  }
}


<# Object helpers #>

function DeepCopy-Object ($obj) {
    $memStr = [io.MemoryStream]::new()
    $fmtBin = [Runtime.Serialization.Formatters.Binary.BinaryFormatter]::new()
    $fmtBin.Serialize($memStr, $obj)
    $memStr.Position=0
    $fmtBin.Deserialize($memStr)
}

# Usage: ... | List-ObjectProps -t | ogv
# FIXME: array as positional argument results in additional property Name=Length
function List-ObjectProps ( [Parameter(Mandatory,ValueFromPipeline)]$obj
                          , [switch]$TruthyOnly ) {
    begin { Set-StrictMode -Off }
    process {
        $obj | Get-Member -MemberType *Property |% Name | Sort-Object -Unique `
        |? { if ($TruthyOnly) {$obj |% $_ |? {$_}} else {$true} } `
        |% { New-Object PSObject -Property $(
                        $v = $obj |% $_
                        if ($obj.Count -gt 1) { $v = $v | Sort-Object -Unique }
                        if ($TruthyOnly) { $v = $v |? {$_} }
                        if ($MyInvocation.ExpectingInput) {
                            $f = $(if ($local:i -lt 100) {(0+$local:i).ToString('00')} else {'##'})
                [ordered]@{'00'=$f;Name=$_;Value=$v}
                        } else {
                [ordered]        @{Name=$_;Value=$v}
                        }
                        )
                }
        ++$local:i
    }
}


<# Str utils #>

# Natural Sort: ... | Sort-Object $_naturally; ... | Sort-Object Extension, { $_.BaseName |% $_naturally }
$_naturally = { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(10, '0') }) }

function normalize-space([string]$str) { # like XPath
    if ([string]::IsNullOrWhiteSpace($str)) { return '' }
    $str -replace '^\s+' -replace '\s+$' -replace '\s+', ' '
}

function Format-Time {
  if ($args.Count -gt 1) {
    $input = $args -join ' '
  } elseif ($args.Count -eq 1) {
    $input = $args[0]
  }
  $input |% { (Get-Date $_ -f s) + (Get-Date $_ -F.fffffff) }
}


<# misc Getters #>

function Get-EnumValues ([string]$enum) { # cannot be of type [type] here
    $enum = [type]( $enum -replace '^\[([^][]+)\]$', '$1' )
    $rslt = [ordered]@{}
    [enum]::GetValues($enum) |% { $rslt.add($_, $_.value__) }
    $rslt
}

function Get-StrictMode { # Set-StrictMode -Version:0
    try { $arr=@(1); $arr[1] } catch { return 3 } # -Version:Latest
    try { "Not-a-Date".Year } catch { return 2 }
    try { $local:undefined } catch { return 1 }
    return 0 # Set-StrictMode -Off
}

function Get-Timestamp {
    if ($args.Count) { throw }
    $datetime = (Get-Date).ToUniversalTime()
    (Get-Date $datetime -f s) + (Get-Date $datetime -F.fffZ)
}

function Get-LoremIpsum { “Lorem ipsum dolor sit amet, consectetur adipiscing elit.  Nam hendrerit nisi sed sollicitudin pellentesque.  Nunc posuere purus rhoncus pulvinar aliquam.  Ut aliquet tristique nisl vitae volutpat.  Nulla aliquet porttitor venenatis.  Donec a dui et dui fringilla consectetur id nec massa.  Aliquam erat volutpat.  Sed ut dui ut lacus dictum fermentum vel tincidunt neque.  Sed sed lacinia lectus.  Duis sit amet sodales felis.  Duis nunc eros, mattis at dui ac, convallis semper risus.  In adipiscing ultrices tellus, in suscipit massa vehicula eu.” }


<# Path generation #>

function New-TemporaryDirectory {
$path = Join-Path ([io.path]::GetTempPath()) ('[_]' + (New-Guid))
$path += '.tmp.d'
New-Item $path -Type Dir |% FullName
}

function ResolveTo-AbsolutePath { [CmdletBinding()] param (
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string[]]$Path
  )
  process {
    $Path|%{ $PSCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($_) }
  }
}


#> CertUtil -EncodeHex -f $FilePath (New-TemporaryFile | tee -Variable f).FullName
function View-FileHexed { [CmdletBinding()] param (
[Parameter(Mandatory=$true)][string]$FilePath
, [int]$HeadCount=20
)
  $i = Get-Item -Force -LiteralPath $FilePath
  if ($PSVersionTable.PSEdition -ceq 'Core') {
    $a = Get-Content $i -TotalCount $HeadCount -Raw -AsByteStream
  } else {
    $a = Get-Content $i -TotalCount $HeadCount -Raw -Encoding Byte
  }
  $a = $a |% { ' {0:x2}' -f $_ }
  -join($a)
}


<# Web Dev helpers #>

function Get-AuthHeader-Basic ([string]${client_id}, [string]${client_secret}) {
    if (${client_id} -match ':') { throw }
    $str = "${client_id}:${client_secret}"
    if ($str -cmatch '[^\x20-\x7E]') { throw }
    return @{Authorization="Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($str)))"}
}

function Format-Json {
$input | ConvertFrom-Json | ConvertTo-Json @args
}

Set-Alias fj Format-Json


function Parse-eyJ { [CmdletBinding()] param (
        [Parameter(ValueFromPipeline)]
        [string[]]$t )
process {
  $t |% {
      $k = $_ -replace '-', '+' -replace '_', '/'
      $k += '=' * ((4 - $k.Length % 4) % 4)
      [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($k)) | fj
  }
} }


function Is-Numeric ($x) {
  try {
    0 + $x | Out-Null # [DBNull|NullString]::Value throw here; [string]::Empty|[AutomationNull]::Value do not
    return ![string]::IsNullOrWhiteSpace($x)
  } catch {
    return $false
  }
}

function Get-Epoch-Timestamp ($x) {
  $epoch = Get-Date 1970-1-1
  Write-Host 'Unix epoch UTC' $epoch -ForegroundColor Yellow

  if (Is-Numeric $x) {
    try {
      $datetime = $epoch.AddSeconds($x)
      $textDate = (Get-Date $datetime -f s)
    } catch [ArgumentOutOfRangeException] {
      Write-Host 'consider arg as milliseconds' -ForegroundColor Yellow
      $datetime = $epoch.AddSeconds($x / 1000)
      $textDate = (Get-Date $datetime -f s) + (Get-Date $datetime -F.fff)
    }
    return $textDate + 'Z'
  }

  if ($null -eq $x) {
    $datetime = (Get-Date).ToUniversalTime()
  } else {
    $datetime = (Get-Date $x).ToUniversalTime()
  }

  Write-Host 'seconds since epoch' -ForegroundColor Yellow
  [Int64] ($datetime - $epoch).TotalSeconds # -is [double]
}



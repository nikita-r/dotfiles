
function Reload-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'User') `
      + ';' + [Environment]::GetEnvironmentVariable('Path', 'Machine')
}

function Test-Elevated {
    $wid = [Security.Principal.WindowsIdentity]::GetCurrent()
    $prp = New-Object Security.Principal.WindowsPrincipal $wid
    $adm = [Security.Principal.WindowsBuiltInRole]::Administrator
    $prp.IsInRole($adm)
}


<# with GridView #>

function Parse-UrlQuery-FromClipboard {
    $url=Get-Clipboard; Write-Host $url
    $q = $url.Substring($url.IndexOf('?')+1).Split('&')
    $q = $q |% { if ('=' -in $_.ToCharArray()) { $_ } else { "$_=" } } | ConvertFrom-StringData
    $q |% { foreach ($key in $($_.Keys)) { $_[$key] = [Net.WebUtility]::UrlDecode($_[$key]) } }
    $q | Out-GridView -PassThru
}


<# view procs #>

function View-Top ($N=8) {
  $dats = Get-Counter "\Process(*)\% Processor Time" -ea:0
  $tots = ($dats.CounterSamples |? InstanceName -eq '_total').CookedValue
  $dats.CounterSamples `
    |? Status -eq 0 |? InstanceName -notIn '_total'<#, 'idle'#> `
    | Sort-Object { $_.InstanceName -eq 'idle' }, CookedValue, @{ E='InstanceName'; D=$false } -Descending | select -First (1 + $N) `
    | Format-Table @{N='Sample TimeStampISO';E={ Get-Date $_.TimeStamp -f s }},
      @{N='Process Name';E={
        $friendlyName = $_.InstanceName
        # try {
        #   $procId = [Diagnostics.Process]::GetProcessesByName($_.InstanceName)[0].Id
        #   $proc = Get-WmiObject -Query "SELECT ProcessId, ExecutablePath FROM Win32_Process WHERE ProcessId=$procId"
        #   $friendlyName = [Diagnostics.FileVersionInfo]::GetVersionInfo($proc.ExecutablePath).FileDescription
        # } catch { }
        if ($friendlyName -eq 'idle') { '[ idle ]' } else { $friendlyName }
      }},
      #@{N='% of CPU';E={ ($_.CookedValue / 100 / $env:NUMBER_OF_PROCESSORS).ToString("P") }} `
      @{N='% of CPU';E={
        if ($_.CookedValue -gt 0) { ($_.CookedValue / $tots).ToString("P") } else { $_.CookedValue }
      };Align='Right'} `
      -a -HideTableHeaders
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



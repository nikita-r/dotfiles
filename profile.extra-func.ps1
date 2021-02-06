
function ResolveTo-AbsolutePath {
  [CmdletBinding()] param (
[Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
[string[]]$Path
  )

  $Path |% { $PSCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($_) }
}

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

function DeepCopy-Object ($obj) {
    $memStr = [io.MemoryStream]::new()
    $fmtBin = [Runtime.Serialization.Formatters.Binary.BinaryFormatter]::new()
    $fmtBin.Serialize($memStr, $obj)
    $memStr.Position=0
    $fmtBin.Deserialize($memStr)
}


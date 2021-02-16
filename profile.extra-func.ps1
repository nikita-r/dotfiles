
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


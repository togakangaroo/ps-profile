function global:sudo
{
    param
    (
	$file = $(throw "The filename of the program is required."), 
	[string]$arguments = $args
     )
    if([System.IO.File]::Exists("$(get-location)\$file"))
    {
      $file = "$(Get-Location)\$file";
    }
    $psi = new-object System.Diagnostics.ProcessStartInfo $file;
    $psi.Arguments = $arguments;
    $psi.Verb = "runas";
    [System.Diagnostics.Process]::Start($psi);
}
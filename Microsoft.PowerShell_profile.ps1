set-alias edit 'C:\Program Files\EditPadPro6\EditPadPro.exe'
"Aliased edit to EditPadPro"
Set-Alias git 'C:\Program Files\Git\bin\git.exe'
"Aliased git"
new-psdrive -name pcs -psprovider FileSystem -root c:\code\pcs
"Set pcs PsDrive"
$prevPaths = new-object system.collections.queue(100)
function go($path, [bool]$quiet=$false) {
  if($path.GetType().Name -eq "Int32") {
	$path = $prevPaths.ToArray()[[int]$path]
  }
  set-location $path
  $prevPaths.enqueue($pwd)
  if(!$quiet) { ls }
}
function gos($path) {
  go $path -quiet $true
}
set-alias cd gos -option allscope
"Created go function"
function svn([string]$command="about") {
  $tortoise = "C:\program files\tortoisesvn\bin\TortoiseProc.exe"
  &$tortoise /command:$command /path:"""$pwd"""
}
"Aliased svn"
function Get-AssemblyInfo($fileList) {
    BEGIN {
        if ($fileList) {$fileList | &($MyInvocation.InvocationName); break;}
	$all = @()
    }
    PROCESS {
	trap [Exception] {
		Write-Host "Error while loading $f"
	}
	if($_.GetType() -eq [string]) { $f = gci $_ }
	else { $f = $_ }
	
	$ass = [system.reflection.assembly]::loadfile($f.FullName)
	$all += $ass.GetName() 
    }
    END {
	$all
    }
}
"Get-AssemblyInfo created"
function ff($pattern="*") {
  $files = gci -include $pattern -recurse 
  $files | select -property FullName | write-host
  $files
}
"ff created"
set-alias new new-object
"new aliased to new-object"
set-alias ss select-string
"ss aliased to select-string"
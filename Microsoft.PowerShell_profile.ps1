set-alias edit 'C:\Program Files\EditPadPro6\EditPadPro.exe'
"Aliased edit to EditPadPro"
Set-Alias git 'C:\Program Files\Git\bin\git.exe'
"Aliased git"
new-psdrive -name pcs -psprovider FileSystem -root c:\code\pcs
"Set pcs PsDrive"
function go($path) {
  cd $path
  ls
}
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
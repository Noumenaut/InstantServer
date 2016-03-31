Update-ExecutionPolicy Unrestricted
Set-ExplorerOptions -showHidenFilesFoldersDrives -showProtectedOSFiles -showFileExtensions
Set-TaskbarSmall
Enable-RemoteDesktop

cinst fiddler4
cinst sysinternals
cinst baretail 
cinst nodejs 
cinst curl
cinst notepadplusplus

cinst IIS-WebServerRole -source windowsfeatures

Install-ChocolateyPinnedTaskBarItem "$env:windir\system32\mstsc.exe"
Install-ChocolateyPinnedTaskBarItem "$env:programfiles\console\console.exe"

Copy-Item (Join-Path -Path (Get-PackageRoot($MyInvocation)) -ChildPath 'console.xml') -Force $env:appdata\console\console.xml

Install-WindowsUpdate -AcceptEula
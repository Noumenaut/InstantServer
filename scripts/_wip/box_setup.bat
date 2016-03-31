# admin console

Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions

# applications
cinst sysinternals
cinst fiddler4
cinst baretail
cinst pstools
cinst nodejs

# windows features
choco windowsfeatures IIS-WebServerRole
choco windowsfeatures IIS-WebServer
choco windowsfeatures IIS-ASPNET
choco windowsfeatures IIS-ASP
choco windowsfeatures IIS-ManagementConsole

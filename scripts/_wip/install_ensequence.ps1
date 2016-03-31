<# March 28th, 2014
+ My First Powershell script to install Einstein components
#>

#Sample execute interact script Command: .\install-Ensequence.ps1 -ReadConfig:$false
[CmdletBinding()]
param (
	[Switch] $ReadConfig = $true
)
# Required setting
set-executionPolicy RemoteSigned
#Set enable-psremoting on localhost
enable-psremoting -force

#Functions
Function initialMe {
#Requirement psexec path
#usage: StartMySession -remoteserverChoice qaitv25 -username "localhost\Administrator" -password Ensequenc3
	param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$remoteserverChoice,
		[Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$username,
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$password
    )
	$pass = ConvertTo-SecureString -string $password -AsPlainText –Force
	$cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist "localhost\$username", $pass
	#try {
	#Set enable-psremoting on remoted server
	#$command = 'C:\Data\Ensequence\Scripts\PsTools\psexec /accepteula \\$remoteserverChoice -u $username -p $password -h -d powershell.exe "enable-psremoting -force"'
	#$command = 'C:\Data\Ensequence\Scripts\PsTools\psexec /accepteula \\$remoteserverChoice -u $username -p $password -h -d powershell.exe Set-ExecutionPolicy RemoteSigned -file "C:\Ensequence\InstallScripts\InitialPS.ps1"'
	cmdkey.exe /add:$remoteserverChoice /user:$remoteserverChoice\Administrator /pass: $password
	$command = '.\PsTools\psexec /accepteula \\$remoteserverChoice -h -d powershell.exe Set-ExecutionPolicy RemoteSigned enable-psremoting -file "C:\Ensequence\InstallScripts\InitialPS.ps1"'
	Invoke-Expression "& $command"

	<#$er = (Invoke-Expression "& $command") 2>&1
	if ($lastexitcode) {throw $er}
    } Catch{
		Write-output "ERROR on Set enable-psremoting on remoted server"
        #Add-Content $log "$TimeStamp - $_"
        Break
    }#>

	cmdkey.exe /delete:$remoteserverChoice
	#Set enable-psremoting on localhost
	#enable-psremoting -force
	#Set Trustedhosts on localhost
	Set-Item -Path WsMan:\localhost\client\TrustedHosts * -Force
	#set-item -Path wsman:localhost\client\trustedhosts *.corp.esq.loc -Force
	#Get-Item -Path WsMan:\localhost\client\TrustedHosts
}

#script for Invoke-Command to Install and Uninstall
$script = {
	param(
		# [parameter(Mandatory=$true)]
		[parameter(Mandatory=$TRUE,Position=0)]
		[String]$nameModule,
		[parameter(Position=1)]
		[string]$serverName, #Replace Server Name with default value in the config file
		[parameter(Position=2)]
		[string]$driveLoc,
		[parameter(Position=3)]
		[int]$poStreamer
	)

	switch ($nameModule ) {
		EnsequencePlayoutWeb {
			$nameInstalledApp = "Ensequence Playout Web Site"
			$msifile= 'C:\Ensequence\InstallScripts\Setups\EnsequencePlayoutWeb\EnsequencePlayoutWeb.msi'
			$arguments= " /quiet /qn INSTALLDIR=$($driveLoc):\Ensequence\PlayoutWebSite "
			$installDir="$($driveLoc):\Ensequence\PlayoutWebSite"
		}
		EinsteinDataService {
			$nameInstalledApp = "Ensequence Data Services"
			$msifile= 'C:\Ensequence\InstallScripts\Setups\DataServices\DataServices.msi'
			$arguments= " /qn INSTALLDIR=$($driveLoc):\Ensequence\DataServices"
			$installDir="$($driveLoc):\Ensequence\DataServices"
		}
		EinsteinStreamerService {
			$nameInstalledApp = "Ensequence Streamer Service"
			$msifile= 'C:\Ensequence\InstallScripts\Setups\EnsequenceStreamerService\StreamerWindowsService.msi'
			$arguments= " /qn INSTALLDIR=$($driveLoc):\Ensequence\StreamerService"
			$installDir="$($driveLoc):\Ensequence\StreamerService"
		}
		EinsteinPlayoutService {
			$nameInstalledApp = "Ensequence Playout Service"
			$msifile= 'C:\Ensequence\InstallScripts\Setups\PlayoutService\PlayoutService.msi'
			Write-output "Playout Variable: $($poStreamer)"
			if ($poStreamer -eq 1) {
				$arguments= " /qn /norestart INSTALLDIR=$($driveLoc):\Ensequence\PlayoutService PLAYOUTSTREAMER=Ensequence BroadcastCenter=PortlandQA Distributor=DistQA"
			} elseif ($poStreamer -eq 2) {
				$arguments= " /qn /norestart INSTALLDIR=$($driveLoc):\Ensequence\PlayoutService PLAYOUTSTREAMER=TSBroadcaster BroadcastCenter=PortlandQA Distributor=DistQA"
			} elseif ($poStreamer -eq 3) {
				$arguments= " /qn /norestart INSTALLDIR=$($driveLoc):\Ensequence\PlayoutService PLAYOUTSTREAMER=File BroadcastCenter=PortlandQA Distributor=DistQA"
			} else {
				$arguments= " /qn /norestart INSTALLDIR=$($driveLoc):\Ensequence\PlayoutService BroadcastCenter=PortlandQA Distributor=DistQA"
			}
			$installDir="$($driveLoc):\Ensequence\PlayoutService"
			#Remove TsbWebService if it has
			Remove-Item "C:\Program Files\Apache Software Foundation\Tomcat 7.0\webapps\TsbWebService\" -Recurse -Force
		}
		SmartAppUI {
			$nameInstalledApp = "SmartAppUI" #Display name in registry
			$msifile= 'C:\Ensequence\InstallScripts\Setups\SmartAppUI\SmartAppUI.msi'
			$arguments= " /qb INSTALLDIR=$($driveLoc):\Ensequence\SmartAppUI APP_POOL_NAME=SmartAppUI"
			$installDir="$($driveLoc):\Ensequence\SmartAppUI"
		}
		NexusManagement {
			$nameInstalledApp = "Ensequence NexusManagement" #Display name in registry
			$msifile= 'C:\Ensequence\InstallScripts\Setups\NexusManagement\iTVManagerNexusManagement.msi'
			$arguments= " /qb INSTALLDIR=$($driveLoc):\Ensequence\NexusManagement APP_POOL_NAME=NexusManagement"
			$installDir="$($driveLoc):\Ensequence\NexusManagement"
		}
		JawsUI {
			$nameInstalledApp = "Ensequence iTVManagerUI" #Display name in registry
			$msifile= 'C:\Ensequence\InstallScripts\Setups\UI\iTVManagerUI.msi'
			$arguments= " /qb INSTALLDIR=$($driveLoc):\Ensequence\iTVManagerUI APP_POOL_NAME=iTVManagerUI"
			$installDir="$($driveLoc):\Ensequence\iTVManagerUI"
		}
		WatermarkUI {
			$nameInstalledApp = "Ensequence WatermarkingUI" #Display name in registry
			$msifile= 'C:\Ensequence\InstallScripts\Setups\WatermarkUI\WatermarkUI.msi'
			$arguments= " /qb INSTALLDIR=$($driveLoc):\Ensequence\WatermarkingUI  APP_POOL_NAME=WatermarkingUI"
			$installDir="$($driveLoc):\Ensequence\WatermarkingUI"
		}
		PublishRouter {
			$nameInstalledApp = "Ensequence iTVManagerPublishRouter" #Display name in registry
			$msifile= 'C:\Ensequence\InstallScripts\Setups\PublishRouter\iTVManagerPublishRouter.msi'
			$arguments= " /qb INSTALLDIR=$($driveLoc):\Ensequence\NexusRouter APP_POOL_NAME=PublishRouter"
			$installDir="$($driveLoc):\Ensequence\NexusRouter"
		}
		MPEGListener {
			$nameInstalledApp = "Ensequence MPEG Listener"
			$msifile= 'C:\Ensequence\InstallScripts\Setups\MPEGListener\MPEGListener.msi'
			Write-output "Mpeglister PLAYOUT_SERVER_NAME is $($serverName) "
			$arguments= " /qb INSTALLDIR=$($driveLoc):\Ensequence\MPEGListenerService PLAYOUT_SERVER_NAME=$($serverName)"
			$installDir="$($driveLoc):\Ensequence\MPEGListenerService"
		}
		ARE {
			$nameInstalledApp = "Ensequence Ad Recognition Service"
			$msifile= 'C:\Ensequence\InstallScripts\Setups\AdRecognitionService\AdRecognitionService.msi'
			Write-output "Mpeglister PLAYOUT_SERVER_NAME is $($serverName) "
			$arguments= " /qb INSTALLDIR=$($driveLoc):\Ensequence\AdRecognitionService\ PLAYOUT_SERVER_NAME=$($serverName)"
			$installDir="$($driveLoc):\Ensequence\AdRecognitionService\"
		}
		PRE {
			$nameInstalledApp = "Ensequence Program Recognition Service"
			$msifile= 'C:\Ensequence\InstallScripts\Setups\ProgramRecognitionEngineService\ProgramRecognitionService.msi'
			$arguments= " /qb INSTALLDIR=$($driveLoc):\Ensequence\ProgramRecognitionService"
			$installDir="$($driveLoc):\Ensequence\ProgramRecognitionService"
		}
	}

	#Write-output "Argument $($arguments) was installed"
	#Write-output "InstallDir $($installDir) was installed"
	$myVer = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  |
	Get-ItemProperty | Where-Object {$_.DisplayName -match $nameInstalledApp } | Select-Object -Property DisplayName, UninstallString
	#Write-output "Find $($myVer.DisplayName) was installed"

	if($myVer.DisplayName -eq $nameInstalledApp){
		#Write-output $app
		Write-output "Uninstall $($nameInstalledApp)"
		$uninst = $myVer.UninstallString
		#
		if ($uninst.StartsWith("msiexec.exe","CurrentCultureIgnoreCase"))
		{
			$ArgumentsUninst = @()
			$ArgumentsUninst += "/Q"
			$ArgumentsUninst += "/X"
			$ArgumentsUninst += $uninst.substring($uninst.indexof("{"),$uninst.Length - $uninst.indexof("{"))
			$ExitCode = (Start-Process -FilePath "msiexec.exe" -ArgumentList $ArgumentsUninst -Wait -Passthru).ExitCode
			if ($ExitCode -ne 0)
			{
				Get-Process | Where-Object {$_.ProcessName -eq "msiexec"} | Stop-Process -Force
				throw "The MSI failed to get uninstalled. MSIEXEC.exe returned an exit code of $ExitCode."
			} else {
				Get-Process | Where-Object {$_.ProcessName -eq "msiexec"} | Stop-Process -Force
				Write-Host "Uninstall completed successfully "
			}
		} else {
			Write-Host "UninstallString is invalid.  Check the register key"
		}

		#start-sleep -Milliseconds 5000

		#Remove old Installed Directory if any then create new installed Directory
		#Remove-Item $installDir -Recurse -Force
		#New-Item -Path $installDir -ItemType "directory" | Out-Null
		#Read-Host '*** Check installed directory is removed '
		if (-not(Test-Path $msifile ))
		{
			Write-output "Can NOT Install  $($nameInstalledApp)!!!"
			#throw "The MSI file of $($nameInstalledApp) isn't available to run installation"
			Write-output "The MSI file of $($nameInstalledApp) isn't available to run installation"
			continue
		} else {
			Write-output "Installing  $($nameInstalledApp) After Uninstall"
			$proc = Start-Process -file  $msifile -arg $arguments -passthru -Wait

		#do {start-sleep -Milliseconds 10000}
		#until ($proc.HasExited)
			Write-output "MSIEXEC.exe returned an exit code of $($proc.ExitCode)."
			if ($proc.ExitCode -ne 0)
			{
				Get-Process | Where-Object {$_.ProcessName -eq "msiexec"} | Stop-Process -Force
				throw "The MSI failed to get uninstalled. MSIEXEC.exe returned an exit code of $($proc)."
			} else {
				Get-Process | Where-Object {$_.ProcessName -eq "msiexec"} | Stop-Process -Force
				Write-Host "Install $($nameInstalledApp) completed successfully"
			}
		}
	} else {
		#Write-output $app
		Write-output "Install $($nameInstalledApp) Without Uninstall "

		#Remove old Installed Directory if any then create new installed Directory
		if (-not(Test-Path -Path $installDir))
		{
			New-Item -Path $installDir -ItemType "directory" | Out-Null
		} else {
			Remove-Item $installDir -Recurse -force
			New-Item -Path $installDir -ItemType "directory" | Out-Null
		}

		if (-not(Test-Path $msifile ))		{
			throw "The MSI file of $($nameInstalledApp) isn't available to run installation"
		} else {
			Write-output "Installing  $($nameInstalledApp) After Uninstall"
			$proc = Start-Process -file  $msifile -arg $arguments -passthru -Wait
		#do {start-sleep -Milliseconds 10000}
		#until ($proc.HasExited)
			Write-output "MSIEXEC.exe returned an exit code of $($proc.ExitCode)."
			if ($proc.ExitCode -ne 0)
			{
				Get-Process | Where-Object {$_.ProcessName -eq "msiexec"} | Stop-Process -Force
				throw "The MSI failed to get uninstalled. MSIEXEC.exe returned an exit code of $($proc.ExitCode)"
			} else {
				Get-Process | Where-Object {$_.ProcessName -eq "msiexec"} | Stop-Process -Force
				Write-Host "Install $($nameInstalledApp) completed successfully"
			}
		}
	}

} #End of Script for Invoke-Command to Install and Uninstall

#Script configurate after install msi
$scriptConfig = {
	param(
		[parameter(Mandatory=$TRUE,Position=0)]
		[String]$nameModule,
		[parameter(Position=1)]
		[string]$serverName, #Replace Server Name with default value in the config file
		[parameter(Position=2)]
		[string]$driveLoc
	)

	switch ($nameModule ) {
		EnsequencePlayoutWeb {
			$installDir="$($driveLoc):\Ensequence\PlayoutWebSite"
			Invoke-Expression -Command '& powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "localhost" -Replacement "$($serverName)" -Path $installDir\Web.config -Overwrite'
		}
		EinsteinDataService {
			$installDir="$($driveLoc):\Ensequence\DataServices"
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "http://localhost/FlightInfoService" -Replacement "http://$($serverName)/FlightInfoService" -Path $installDir\Ensequence.DataServicesHost.exe.config -Overwrite'
			# For Production Jurassic only
			#Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "qa-proxysaurus-jurassic.ensequence.com" -Replacement "proxysaurus.synqtv.com" -Path $installDir\Ensequence.DataServicesHost.exe.config -Overwrite'
			#Invoke-Expression -Command 'C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "..\..\..\EmulationData" -Replacement "C:\EmulationData" -Path $installDir\Ensequence.DataServicesHost.exe.config -Overwrite'
		}
		EinsteinStreamerService {
			$installDir="$($driveLoc):\Ensequence\StreamerService"
			#Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "http://localhost/FlightInfoService" -Replacement "http://$($serverName)/FlightInfoService" -Path $installDir\StreamerWindowsService.config -Overwrite'
			# For Production Jurassic only
			#Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "qa-proxysaurus-jurassic.ensequence.com" -Replacement "proxysaurus.synqtv.com" -Path $installDir\Ensequence.DataServicesHost.exe.config -Overwrite'
			#Invoke-Expression -Command 'C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "..\..\..\EmulationData" -Replacement "C:\EmulationData" -Path $installDir\Ensequence.DataServicesHost.exe.config -Overwrite'
		}
		EinsteinPlayoutService {
			$myComputer = (Get-Item env:\COMPUTERNAME).value
			$installDir="$($driveLoc):\Ensequence\PlayoutService"
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "http://localhost/ResourceUpdateService" -Replacement "http://$($myComputer)/ResourceUpdateService" -Path $installDir\bin\Ensequence.PlayoutWindowsService.exe.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "http://localhost:8097/FeedService" -Replacement "http://$($serverName):8097/FeedService" -Path $installDir\bin\Ensequence.PlayoutWindowsService.exe.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "http://localhost:8097/FeedService/" -Replacement "http://$($serverName):8097/FeedService/" -Path $installDir\bin\Ensequence.PlayoutWindowsService.exe.config -Overwrite'
			#For QA
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "10MB" -Replacement "100MB" -Path $installDir\bin\Ensequence.PlayoutWindowsService.exe.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "localhost:64479" -Replacement "10.10.200.201:81" -Path $installDir\bin\Ensequence.PlayoutWindowsService.exe.config -Overwrite'
			#Modify install different location
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "C:" -Replacement "$($driveLoc):" -Path $installDir\bin\Ensequence.PlayoutWindowsService.exe.config -Overwrite'
			#Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "`<add key=`"Streamer`" value=`"Ensequence`" /`>" -Replacement "`<add key=`"Streamer`" value=`"TSBroadcaster`" /`>" -Path $installDir\bin\Ensequence.PlayoutWindowsService.exe.config -Overwrite'
			#Modify the setup DB script for install different location
			#Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "DATAHOME=C:" -Replacement "DATAHOME=$($driveLoc):" -Path $installDir\Database\Setup\Deploy_iTVBroadcastDB.bat -Overwrite'
		}
		SmartAppUI {
			$myComputer = (Get-Item env:\COMPUTERNAME).value
			$installDir="$($driveLoc):\Ensequence\SmartAppUI"
			Copy-Item -Path $installDir\Web.config -Destination $installDir\WebBackup.config -force
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "https://smartapp.ensequence.com" -Replacement "https://localhost:1450" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "localhost" -Replacement "$($myComputer)" -Path $installDir\Web.config -Overwrite'
		}
		JawsUI {
			$myComputer = (Get-Item env:\COMPUTERNAME).value
			$installDir="$($driveLoc):\Ensequence\iTVManagerUI"
			Copy-Item -Path $installDir\Web.config -Destination $installDir\WebBackup.config -force
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "https://author.ensequence.com" -Replacement "http://localhost:1450" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "localhost" -Replacement "$($myComputer)" -Path $installDir\Web.config -Overwrite'

		}
		WatermarkUI {
			$myComputer = (Get-Item env:\COMPUTERNAME).value
			$installDir="$($driveLoc):\Ensequence\WatermarkingUI"
			Copy-Item -Path $installDir\Web.config -Destination $installDir\WebBackup.config -force
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "https://watermarking.ensequence.com" -Replacement "http://localhost:1450" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "https://watermark.ensequence.com" -Replacement "http://localhost:1450" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "localhost" -Replacement "$($myComputer)" -Path $installDir\Web.config -Overwrite'
		}
		NexusManagement {
			$myComputer = (Get-Item env:\COMPUTERNAME).value
			$installDir="$($driveLoc):\Ensequence\NexusManagement"
			Copy-Item -Path $installDir\Web.config -Destination $installDir\WebBackup.config -force
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "https://author.ensequence.com" -Replacement "http://localhost:1450" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "localhost" -Replacement "$($myComputer)" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "192.168.11.3" -Replacement "$($serverName)" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "Denver" -Replacement "$($serverName)" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "192.168.12.3" -Replacement "qa-vm07" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "Atlanta" -Replacement "2ndEinstein" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "http://nexusaurus.synqtv.com" -Replacement "http://qa-nexusaurus-jurassic.ensequence.com" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "ens-datasets" -Replacement "ens-dev" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "http://zeusasaurus.synqtv.com" -Replacement "http://qa-gateway-esq.herokuapp.com" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "http://stats.synqtv.com:3000" -Replacement "http://198.61.238.145:3000" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "http://customer.synqtv.com:8003" -Replacement "https://qa-gateway-esq.herokuapp.com/api/v1" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "fdf86373559f4f019c5eb52c8c71d9f3" -Replacement "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJlaW5zdGVpbiIsImRhdGEiOnsicGVybWlzc2lvbnMiOnsiZW5zZXF1ZW5jZSI6WyJhZG1pbiJdfX0sImlhdCI6MTQzNTE3NzExOH0.XDNIhd3pQn9exagzRDiws6A8FXhIofUTMtVUkLgH13g" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "ens-nexus" -Replacement "ens-dev" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "http://d392og3ya8ev1q.cloudfront.net" -Replacement "http://d3ac2cvo49fi1z.cloudfront.net" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "aws.credentials" -Replacement "Ensequence/aws/aws.credentials" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "D:" -Replacement "$($driveLoc):" -Path $installDir\Web.config -Overwrite'
			#Modify the setup DB script for install different location
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "DATAHOME=C:" -Replacement "DATAHOME=$($driveLoc):" -Path C:\Ensequence\InstallScripts\Setups\SetupScripts\Deploy_iTVManagerDataBase.bat -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "C:" -Replacement "$($driveLoc):" -Path C:\Ensequence\InstallScripts\Setups\SetupScripts\SQL\iTVManager_CreateDB.sql -Overwrite'
		}
		PublishRouter {
			$installDir="$($driveLoc):\Ensequence\NexusRouter"
			Copy-Item -Path $installDir\Web.config -Destination $installDir\WebBackup.config -force
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "192.168.11.3" -Replacement "$($serverName)" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "Denver" -Replacement "$($serverName)" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "192.168.12.3" -Replacement "qa-vm07" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "Atlanta" -Replacement "2ndEinstein" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "INFO" -Replacement "DEBUG" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "ens-nexus" -Replacement "ens-dev" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "http://d392og3ya8ev1q.cloudfront.net" -Replacement "http://d3ac2cvo49fi1z.cloudfront.net" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "AWS.credentials" -Replacement "Ensequence/aws/aws.credentials" -Path $installDir\Web.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "D:" -Replacement "$($driveLoc):" -Path $installDir\Web.config -Overwrite'

		}

		MPEGListener {
			$myComputer = (Get-Item env:\COMPUTERNAME).value
			$installDir="$($driveLoc):\Ensequence\MPEGListenerService"
			#Invoke-Expression -Command @'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "<add key="myhostname" value="localhost"/>" -Replacement "<add key="myhostname" value="$($myComputer)"/>" -Path $installDir\MPEGListenerService.exe.config -Overwrite'@
			#Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "`<add key=`"myhostname`" value=\"localhost\"/\>" -Replacement "\<add key=\"myhostname\" value=\"$($myComputer)\"/\>" -Path $installDir\MPEGListenerService.exe.config -Overwrite'
			#Invoke-Expression -Command @'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "<add key="ServiceHost" value="localhost"/>" -Replacement "<add key="ServiceHost" value="$($serverName)"/>" -Path $installDir\MPEGListenerService.exe.config -Overwrite'@
			#Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "\<add key=\"ServiceHost\" value=\"localhost\"/\>" -Replacement "\<add key=\"ServiceHost\" value=\"$($serverName)\"/\>" -Path $installDir\MPEGListenerService.exe.config -Overwrite'
		}
		ARE {
			$myComputer = (Get-Item env:\COMPUTERNAME).value
			$installDir="$($driveLoc):\Ensequence\AdRecognitionService\"
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "localhost" -Replacement "$($myComputer)" -Path $installDir\AdRecognitionService.exe.config -Overwrite'
			Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "localhost" -Replacement "$($serverName)" -Path $installDir\AdRecognitionServiceConfig.xml -Overwrite'

		}
		PRE {
			$myComputer = (Get-Item env:\COMPUTERNAME).value
			$installDir="$($driveLoc):\Ensequence\ProgramRecognitionService"
			#Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "`<add key=`"AudioEngineHost`" value=`"localhost`"/`>" -Replacement "`<add key=`"AudioEngineHost`" value=`"$($myComputer)`"/`>" -Path $installDir\ProgramRecognitionService.exe.config -Overwrite'
			#Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "PlayoutHost=`"localhost`"" -Replacement "PlayoutHost=`"$($serverName)`"" -Path $installDir\ProgramRecognitionService.exe.config -Overwrite'
			#Invoke-Expression -Command 'powershell.exe -noprofile -executionpolicy Bypass C:\Ensequence\InstallScripts\Replace-FileString.ps1 -Pattern "`<add key=`"AudioSocketIPAddress`" value=`"localhost`"/`>" -Replacement "`<add key=`"AudioSocketIPAddress`" value=`"$($myComputer)`"/`>" -Path $installDir\PREngine.exe.config -Overwrite'
		}
	}
} # End of ScriptConfig function

#Script resetServer after install msi
$resetServer = {
	param( $moduleName )
	switch ($moduleName ) {
		Einstein {
			$moduleName = @("Playout Web Site")
		}
		Nexus {
			$moduleName = @("iTVManagerUI","WatermarkingUI","NexusManagement","PublishRouter")
		}
	}
	Import-Module WebAdministration
	#$moduleName = @("iTVManagerUI","WatermarkingUI","NexusManagement","PublishRouter")

	##set ALL app pool disallowOverlappingRotation True
	Set-WebConfigurationProperty '/system.applicationHost/applicationPools/applicationPoolDefaults/recycling' -name "DisallowOverlappingRotation" -value "True" -Force
	##Setup up Application Initilization required parameters
	Set-WebConfigurationProperty '/system.applicationHost/applicationPools/add[@name="PublishRouter"]'  -name "startMode" -value "AlwaysRunning" -Force
	Set-WebConfigurationProperty '/system.applicationHost/applicationPools/add[@name="PublishRouter"]'  -name "autoStart" -value "True" -Force
	write-output "Start reset $($moduleName.length) the Websites and AppPool "
	# Get all running app pools
	for ($i=0; $i -lt $moduleName.length; $i++) {

		$webState =  Get-WebsiteState -Name $($moduleName[$i])
		$appPoolState = Get-WebAppPoolState "$($moduleName[$i])"

		if ($webState.Value -eq "Started")
		{
			#Restart only the Website is running
			Restart-WebItem iis:\sites\$($moduleName[$i])
			write-output "Restart Website: $($moduleName[$i])"
		} else {
			Start-Website -name $($moduleName[$i])
			write-output "Start Website: $($moduleName[$i])"
		}
		if ($appPoolState.Value -eq "Started")
		{
			#Restart only the appPool is running
			Restart-WebItem iis:\apppools\$($moduleName[$i])
			write-output "Restart AppPool: $($moduleName[$i])"
		} else {
			Start-WebAppPool -name $($moduleName[$i])
			write-output "Start AppPool: $($moduleName[$i])"
		}

	}
}# End of resetServer function

#Function InstallMe
#Usage: InstallMe -compChoice 1, 2, 3 or 4
Function InstallMe {
	param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [int]$compChoice
    )


	switch ($compChoice)
	{
		1 {
			Write-Output "== Checking Drive $($EinsteinDrive) availability on this $($serverChoiceEinstein) server =="
			##Copy to Remote Server
			net use \\$serverChoiceEinstein\$EinsteinDrive$ /USER:$userName $userPwd
			Write-Output "== %%%778=="

			if ($LASTEXITCODE -ne 0) {
				Write-Output "== Drive $($EinsteinDrive) is not available for installation on this $($serverChoiceEinstein) server =="
				net use \\$serverChoiceEinstein\$EinsteinDrive$ /delete
				exit
			}

			#Write-Output $compChoice
			Write-Output $sourceBld
			$destLoc = "\\$serverChoiceEinstein\C$\Ensequence\"
			$destTomcat = "C:\Program Files\Apache Software Foundation\Tomcat 7.0\"

			#Copy to Remote Server
			if (-not(Test-Path -Path "$($destLoc)\InstallScripts\Setups\"))
			{
				New-Item -Path "$($destLoc)\InstallScripts\Setups\" -type directory -force
			}

			# Copy initial setup for remote server
			if (-not(Test-Path -Path "$($destLoc)\InstallScripts\InitialPS.ps1"))
			{
				echo f | xcopy .\InitialPS.ps1 $destLoc\InstallScripts /fYeQV
			}
			if (-not(Test-Path -Path "$($destLoc)\InstallScripts\Replace-FileString.ps1"))
			{
				echo f | xcopy .\Replace-FileString.ps1 $destLoc\InstallScripts /fYeQV
			}

			initialMe -remoteserverChoice $serverChoiceEinstein -username $userName -password $userPwd

			#Wait for finishing initialMe process including delete the temporary Setups Directory
			start-sleep -Milliseconds 5000
			if((Test-Path $destLoc))
			{
				# Copy msi Release
				echo d | xcopy $sourceBld\EnsequencePlayoutWeb $destLoc\InstallScripts\Setups\EnsequencePlayoutWeb /fYeQV
				#echo d | xcopy $sourceBld\DataServices $destLoc\InstallScripts\Setups\DataServices /fYeQV
				echo d | xcopy $sourceBld\PlayoutService $destLoc\InstallScripts\Setups\PlayoutService /fYeQV
				#Ensequence Streamer
				echo d | xcopy $sourceBld\EnsequenceStreamerService $destLoc\InstallScripts\Setups\EnsequenceStreamerService /fYeQV
				#Copy TSBroadcast files - need to remove when installer includes these files
				echo f | xcopy $sourceBld\tsbWebService\*.xml $destLoc /fYeQV
				echo f | xcopy $sourceBld\tsbWebService\*.jar $destTomcat\lib /fYeQV
				echo f | xcopy $sourceBld\tsbWebService\*.war $destTomcat\webapps /fYeQV
			} else {
				Read-Host '*** Can not see copy files. Check copied $($destLoc) directory '
			}

			$passwd = convertto-securestring -AsPlainText -Force -String $userPwd

			$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName,$passwd

			$mySesEinstein1 = New-PSSession -computerName $serverChoiceEinstein -credential $cred
			enter-pssession -session $mySesEinstein1
			Write-output "enter PSSession on remoted server $($serverChoiceEinstein)"
			#Uninstall Remotely

			Write-Host "Start to Installation on $($serverChoiceEinstein) on $($EinsteinDrive)"

			#$nameModule = "EnsequencePlayoutWeb"
			Invoke-Command -Session $mySesEinstein1 -scriptblock $script -Args "EnsequencePlayoutWeb", $serverChoiceEinstein, $EinsteinDrive, $setPlayoutVariable
			#Modify Configuration file
			Invoke-Command -Session $mySesEinstein1 -scriptblock $scriptConfig -Args "EnsequencePlayoutWeb", $serverChoiceEinstein, $EinsteinDrive
			#$nameModule = "EinsteinDataService" - 2.4 Release doesn't included this module
			#Invoke-Command -Session $mySesEinstein1 -scriptblock $script -Args "EinsteinDataService", $EinsteinDrive
			#Modify Configuration file	- 2.4 Release doesn't included this module
			# Invoke-Command -Session $mySesEinstein1 -scriptblock $scriptConfig -Args "EinsteinDataService", $serverChoiceEinstein, $EinsteinDrive
			#Install Playout module
			#$nameModule = "EinsteinPlayoutService"
			Invoke-Command -Session $mySesEinstein1 -scriptblock $script -Args "EinsteinPlayoutService", $serverChoiceEinstein, $EinsteinDrive, $setPlayoutVariable
			#Modify Configuration file
			Invoke-Command -Session $mySesEinstein1 -scriptblock $scriptConfig -Args "EinsteinPlayoutService", $serverChoiceEinstein, $EinsteinDrive
			#Install Ensequence Streamer module
			#Temporary install Ensequence Streamer on Same Playout Server.  If wants different server use switch #5 below and setting in Settings.xml
			Invoke-Command -Session $mySesEinstein1 -scriptblock $script -Args "EinsteinStreamerService", $serverChoiceEinstein, $EinsteinDrive, $setPlayoutVariable
			#Reset Playout DB
			If ($resetEinsteinDB -eq 1) {
				Invoke-Command -Session $mySesEinstein1 -scriptblock {
					param([string]$driveLoc)
					push-location "$($driveLoc):\Ensequence\PlayoutService\Database\Setup\"
					invoke-expression -Command ".\Deploy_iTVBroadcastDB.bat"
				} -Args $EinsteinDrive
			}
			If ($resetEinsteinDB -eq 2) {
				Invoke-Command -Session $mySesEinstein1 -scriptblock {
					param([string]$driveLoc)
					push-location "$($driveLoc):\Ensequence\PlayoutService\Database\Setup\"
					invoke-expression -Command ".\Deploy_CleaniTVBroadcastDB.bat"
				} -Args $EinsteinDrive
			}

			if ($resetEinstein -eq 1) {
				$moduleName = "Einstein"
				Invoke-Command -Session $mySesEinstein1 -scriptblock $resetServer -Args $moduleName
			}
			#Disable PSRemoting on Remote computer
			Invoke-Command -Session $mySesEinstein1 -scriptblock {
				Disable-PSRemoting -Force | Out-Null
			}
			# Remove Session
			Remove-PSSession $mySesEinstein1 | Out-Null
			net use \\$serverChoiceEinstein\$EinsteinDrive$ /delete
		}
		2 { # Installing multiple Einstein servers

			Write-Output "== Checking Drive $($EinsteinDrive) availability on this $($serverChoiceEnsequencePlayoutWeb) server =="
			##Check Playout Web UI
			net use \\$serverChoiceEnsequencePlayoutWeb\$EinsteinDrive$ /USER:$userName $userPwd
			if ($LASTEXITCODE -ne 0) {
				Write-Output "== Drive $($EinsteinDrive) is not available for installation on this $($serverChoiceEnsequencePlayoutWeb) server =="
				net use \\$serverChoiceEnsequencePlayoutWeb\$EinsteinDrive$ /delete
				exit
			}
			##Check Einstein Playout Server
			net use \\$serverChoiceEinsteinPlayout\$EinsteinDrive$ /USER:$userName $userPwd
			if ($LASTEXITCODE -ne 0) {
				Write-Output "== Drive $($EinsteinDrive) is not available for installation on this $($serverChoiceEinsteinPlayout) server =="
				net use \\$serverChoiceEinsteinPlayout\$EinsteinDrive$ /delete
				exit
			}
			Write-Output "Get the build from $($sourceBld) to $($serverChoiceEnsequencePlayoutWeb) and $($serverChoiceEinsteinPlayout)"
			$destLocUI = "\\$serverChoiceEnsequencePlayoutWeb\C$\Ensequence\"
			$destLocPO = "\\$serverChoiceEinsteinPlayout\C$\Ensequence\"
			$destTomcat = "C:\Program Files\Apache Software Foundation\Tomcat 7.0\"

			#Copy to Remoted Server
			net use \\$serverChoiceEinsteinPlayout /USER:$userName $userPwd
			# Copy initial setup for remote server
			if (-not(Test-Path -Path "$($destLocUI)\InstallScripts\InitialPS.ps1"))
			{
				echo f | xcopy .\InitialPS.ps1 $destLocUI\InstallScripts /fYeQV
			}
			if (-not(Test-Path -Path "$($destLocPO)\InstallScripts\InitialPS.ps1"))
			{
				echo f | xcopy .\InitialPS.ps1 $destLocPO\InstallScripts /fYeQV
			}
			if (-not(Test-Path -Path "$($destLocUI)\InstallScripts\Replace-FileString.ps1"))
			{
				echo f | xcopy .\Replace-FileString.ps1 $destLocUI\InstallScripts /fYeQV
			}
			if (-not(Test-Path -Path "$($destLocPO)\InstallScripts\Replace-FileString.ps1"))
			{
				echo f | xcopy .\Replace-FileString.ps1 $destLocPO\InstallScripts /fYeQV
			}

			initialMe -remoteserverChoice $serverChoiceEnsequencePlayoutWeb -username $userName -password $userPwd
			initialMe -remoteserverChoice $serverChoiceEinsteinPlayout -username $userName -password $userPwd

			#Wait for finishing initialMe process including delete the temporary Setups Directory
			start-sleep -Milliseconds 3000
			if((Test-Path $destLocUI\InstallScripts))
			{
				# Copy msi Release
				echo d | xcopy $sourceBld\EnsequencePlayoutWeb $destLocUI\InstallScripts\Setups\EnsequencePlayoutWeb /fYeQV
				echo d | xcopy $sourceBld\DataServices $destLocUI\InstallScripts\Setups\DataServices /fYeQV
			} else {
				Read-Host '*** Can not see copy files. Check copied $($destLocUI) directory '
			}
			if((Test-Path $destLocPO\InstallScripts))
			{
				# Copy msi Release
				echo d | xcopy $sourceBld\PlayoutService $destLocPO\InstallScripts\Setups\PlayoutService /fYeQV
				#Ensequence Streamer
				echo d | xcopy $sourceBld\EnsequenceStreamerService $destLoc\InstallScripts\Setups\EnsequenceStreamerService /fYeQV
				#Copy TSBroadcast files - need to remove when installer includes these files

				echo f | xcopy $sourceBld\tsbWebService\*.xml $destLoc /fYeQV
				echo f | xcopy $sourceBld\tsbWebService\*.jar $destTomcat\lib /fYeQV
				echo f | xcopy $sourceBld\tsbWebService\*.war $destTomcat\webapps /fYeQV
			} else {
				Read-Host '*** Can not see copy files. Check copied $($destLocPO) directory '
			}
			Get-Item -Path WsMan:\localhost\client\TrustedHosts
			$passwd = convertto-securestring -AsPlainText -Force -String $userPwd

			$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName,$passwd

			$mySesEinstein1 = New-PSSession -computerName $serverChoiceEnsequencePlayoutWeb -credential $cred
			enter-pssession -session $mySesEinstein1
			Write-output "enter PSSession on remoted server $($serverChoiceEnsequencePlayoutWeb)"
			Write-Host "Start to Installation on $($serverChoiceEnsequencePlayoutWeb)"
			#$nameModule = "EnsequencePlayoutWeb"
			Invoke-Command -Session $mySesEinstein1 -scriptblock $script -Args "EnsequencePlayoutWeb", $serverChoiceEinstein, $EinsteinDrive, $setPlayoutVariable
			#Modify Configuration file
			Invoke-Command -Session $mySesEinstein1 -scriptblock $scriptConfig -Args "EnsequencePlayoutWeb", $serverChoiceEinsteinPlayout, $EinsteinDrive

			#$nameModule = "EinsteinDataService" - 2.4 Release doesn't included this module
			#Invoke-Command -Session $mySesEinstein1 -scriptblock $script -Args "EinsteinDataService", $EinsteinDrive
			#Modify Configuration file - 2.4 Release doesn't included this module
			#Invoke-Command -Session $mySesEinstein1 -scriptblock $scriptConfig -Args "EinsteinDataService", $serverChoiceEinsteinPlayout, $EinsteinDrive

			$mySesEinstein2 = New-PSSession -computerName $serverChoiceEinsteinPlayout -credential $cred
			enter-pssession -session $mySesEinstein2
			Write-output "enter PSSession on remoted server $($serverChoiceEinsteinPlayout)"
			#Uninstall Remotely
			Write-Host "Start to Installation on $($serverChoiceEinsteinPlayout) on $($EinsteinDrive)"

			#$nameModule = "EinsteinPlayoutService"
			Invoke-Command -Session $mySesEinstein2 -scriptblock $script -Args "EinsteinPlayoutService", $serverChoiceEnsequencePlayoutWeb, $EinsteinDrive, $setPlayoutVariable
			#Modify Configuration file
			Invoke-Command -Session $mySesEinstein2 -scriptblock $scriptConfig -Args "EinsteinPlayoutService", $serverChoiceEnsequencePlayoutWeb, $EinsteinDrive
			#Install Ensequence Streamer module
			#Temporary install Ensequence Streamer on Same Playout Server.  If wants different server use switch #5 below and setting in Settings.xml
			Invoke-Command -Session $mySesEinstein2 -scriptblock $script -Args "EinsteinStreamerService", $serverChoiceEnsequencePlayoutWeb, $EinsteinDrive, $setPlayoutVariable

			#Reset Playout DB
			If ($resetEinsteinDB -eq 1) {
				Invoke-Command -Session $mySesEinstein2 -scriptblock {
					param([string]$driveLoc)
					push-location "$($driveLoc):\Ensequence\PlayoutService\Database\Setup\"
					invoke-expression -Command ".\Deploy_iTVBroadcastDB.bat"
				} -Args $EinsteinDrive
			}
			If ($resetEinsteinDB -eq 2) {
				Invoke-Command -Session $mySesEinstein2 -scriptblock {
					param([string]$driveLoc)
					push-location "$($driveLoc):\Ensequence\PlayoutService\Database\Setup\"
					invoke-expression -Command ".\Deploy_CleaniTVBroadcastDB.bat"
				} -Args $EinsteinDrive
			}
			if ($resetEinstein -eq 1) {
				$moduleName = "Einstein"
				Invoke-Command -Session $mySesEinstein1 -scriptblock $resetServer -Args $moduleName
			}
			Invoke-Command -Session $mySesEinstein1 -scriptblock { Disable-PSRemoting -Force }
			Invoke-Command -Session $mySesEinstein2 -scriptblock { Disable-PSRemoting -Force }

			# Remove Session
			Remove-PSSession $mySesEinstein1
			Remove-PSSession $mySesEinstein2
			net use \\$serverChoiceEnsequencePlayoutWeb\$EinsteinDrive$ /delete
			net use \\$serverChoiceEinsteinPlayout\$EinsteinDrive$ /delete
			#Write-Output $compChoice
		}
		3 {  #Install Multicast system: Mpeglistner, ARE, and PRE
			Write-Output "== Checking Drive $($EinsteinDrive) availability on this $($serverChoiceMulticast) server =="
			##Copy to Remote Server
			net use \\$serverChoiceMulticast\$EinsteinDrive$ /USER:$userName $userPwd
			if ($LASTEXITCODE -ne 0) {
				Write-Output "== Drive $($EinsteinDrive) is not available for installation on this $($serverChoiceMulticast) server=="
				net use \\$serverChoiceMulticast\$EinsteinDrive$ /delete
				exit
			}

			Write-Output $sourceBld
			$destLoc = "\\$serverChoiceMulticast\C$\Ensequence\"

			# Copy initial setup for remote server
			if (-not(Test-Path -Path "$($destLoc)\InstallScripts\InitialPS.ps1"))
			{
				echo f | xcopy .\InitialPS.ps1 $destLoc\InstallScripts /fYeQV
			}
			if (-not(Test-Path -Path "$($destLoc)\InstallScripts\Replace-FileString.ps1"))
			{
				echo f | xcopy .\Replace-FileString.ps1 $destLoc\InstallScripts /fYeQV
			}

			initialMe -remoteserverChoice $serverChoiceMulticast -username $userName -password $userPwd

			#Wait for finishing initialMe process including delete the temporary Setups Directory
			start-sleep -Milliseconds 5000
			if((Test-Path $destLoc))
			{
				# Copy msi Release
				echo d | xcopy $sourceBld\ProgramRecognitionEngineService $destLoc\InstallScripts\Setups\ProgramRecognitionEngineService /fYeQV
				echo d | xcopy $sourceBld\MPEGListener $destLoc\InstallScripts\Setups\MPEGListener /fYeQV
				echo d | xcopy $sourceBld\AdRecognitionService $destLoc\InstallScripts\Setups\AdRecognitionService /fYeQV

			} else {
				Read-Host '*** Can not see copy files. Check copied $($destLoc) directory '
			}

			$passwd = convertto-securestring -AsPlainText -Force -String $userPwd

			$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName,$passwd

			$myMulticast1 = New-PSSession -computerName $serverChoiceMulticast -credential $cred
			enter-pssession -session $myMulticast1
			Write-output "enter PSSession on remoted server $($serverChoiceMulticast)"
			#Uninstall Remotely

			Write-Host "Start to Installation on $($serverChoiceMulticast)"

			Invoke-Command -Session $myMulticast1 -scriptblock $script -Args "MPEGListener", $serverChoicePO, $EinsteinDrive, $setPlayoutVariable
			#Modify Configuration file
			#Invoke-Command -Session $myMulticast1 -scriptblock $scriptConfig -Args "MPEGListener", $serverChoicePO, $EinsteinDrive
			Invoke-Command -Session $myMulticast1 -scriptblock $script -Args "ARE", $serverChoicePO, $EinsteinDrive, $setPlayoutVariable
			#Modify Configuration file
			Invoke-Command -Session $myMulticast1 -scriptblock $scriptConfig -Args "ARE", $serverChoicePO, $EinsteinDrive
			#Install PRE module	- 2.4 Release doesn't included this module
			#Invoke-Command -Session $myMulticast1 -scriptblock $script -Args "PRE", $EinsteinDrive
			#Modify Configuration file - 2.4 Release doesn't included this module
			#Invoke-Command -Session $myMulticast1 -scriptblock $scriptConfig -Args "PRE", $serverChoicePO, $EinsteinDrive


			#Disable PSRemoting on Remote computer
			#Invoke-Command -Session $myMulticast1 -scriptblock {
			#	Disable-PSRemoting -Force | Out-Null
			#}
			# Remove Session
			Remove-PSSession $myMulticast1 | Out-Null
			net use \\$serverChoiceMulticast\$EinsteinDrive$ /delete

		}
		4 { # Installing Nexus modules


			$destLoc = "\\$serverChoiceNexus\C$\Ensequence\"
			Write-Output "== Checking Drive $($NexusDrive) availability on this $($serverChoiceNexus) server =="
			##Copy to Remote Server
			net use \\$serverChoiceNexus\$NexusDrive$ /USER:$userName $userPwd
			if ($LASTEXITCODE -ne 0) {
				Write-Output "== Drive $($NexusDrive) is not available for installation on this $($serverChoiceNexus) server=="
				net use \\$serverChoiceNexus\$NexusDrive$ /delete
				exit
			}
			Write-Output $sourceNexusBld

			# Copy initial setup for remote server
			if (-not(Test-Path -Path "$($destLoc)\InstallScripts\InitialPS.ps1"))
			{
				echo f | xcopy .\InitialPS.ps1 $destLoc\InstallScripts\InitialPS.ps1 /fYeQV
			}
			if (-not(Test-Path -Path "$($destLoc)\InstallScripts\Replace-FileString.ps1"))
			{
				echo f | xcopy .\Replace-FileString.ps1 $destLoc\InstallScripts\Replace-FileString.ps1 /fYeQV
			}

			initialMe -remoteserverChoice $serverChoiceNexus -username $userName -password $userPwd
			#Wait for finishing initialMe process including delete the temporary Setups Directory
			start-sleep -Milliseconds 5000
			if((Test-Path $destLoc))
			{
				# Copy msi Release
				echo d | xcopy $sourceNexusBld\UI $destLoc\InstallScripts\Setups\UI /fYeQV
				#echo d | xcopy $sourceNexusBld\SmartAppUI $destLoc\InstallScripts\Setups\SmartAppUI /fYeQV
				echo d | xcopy $sourceNexusBld\WatermarkUI $destLoc\InstallScripts\Setups\WatermarkUI /fYeQV
				echo d | xcopy $sourceNexusBld\NexusManagement $destLoc\InstallScripts\Setups\NexusManagement /fYeQV
				echo d | xcopy $sourceNexusBld\PublishRouter $destLoc\InstallScripts\Setups\PublishRouter /fYeQV
				echo d | xcopy $sourceNexusBld\SetupScripts $destLoc\InstallScripts\Setups\SetupScripts /fYeQV

			} else {
				Read-Host '*** Can not see copy files. Check copied $($destLoc) directory '
			}

			$passwd = convertto-securestring -AsPlainText -Force -String $userPwd
			$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName,$passwd

			$mySesNexus1 = New-PSSession -computerName $serverChoiceNexus -credential $cred
			enter-pssession -session $mySesNexus1
			Write-output "enter PSSession on remoted server $($serverChoiceNexus)"
			#Uninstall Remotely

			Write-Host "Start to Installation on $($serverChoiceNexus) on $($NexusDrive) Drive"

			#$nameModule = "SmartAppUI"
			#Invoke-Command -Session $mySesNexus1 -scriptblock $script -Args "SmartAppUI"
			#Invoke-Command -Session $mySesNexus1 -scriptblock $scriptConfig -Args "SmartAppUI", $serverPubEinstein
			$nameModule = "NexusManagement"
			Invoke-Command -Session $mySesNexus1 -scriptblock $script -Args "NexusManagement", $serverPubEinstein, $NexusDrive, $setPlayoutVariable
			#Modify Configuration file
			Invoke-Command -Session $mySesNexus1 -scriptblock $scriptConfig -Args "NexusManagement", $serverPubEinstein, $NexusDrive

			$nameModule = "JawsUI"
			Invoke-Command -Session $mySesNexus1 -scriptblock $script -Args "JawsUI", $serverPubEinstein, $NexusDrive, $setPlayoutVariable
			#Modify Configuration file
			Invoke-Command -Session $mySesNexus1 -scriptblock $scriptConfig -Args "JawsUI", $serverPubEinstein, $NexusDrive
			$nameModule = "WatermarkUI"
			Invoke-Command -Session $mySesNexus1 -scriptblock $script -Args "WatermarkUI",$serverPubEinstein, $NexusDrive, $setPlayoutVariable
			#Modify Configuration file
			Invoke-Command -Session $mySesNexus1 -scriptblock $scriptConfig -Args "WatermarkUI", $serverPubEinstein, $NexusDrive
			$nameModule = "PublishRouter"
			Invoke-Command -Session $mySesNexus1 -scriptblock $script -Args "PublishRouter",$serverPubEinstein, $NexusDrive, $setPlayoutVariable
			#Modify Configuration file
			Invoke-Command -Session $mySesNexus1 -scriptblock $scriptConfig -Args "PublishRouter", $serverPubEinstein, $NexusDrive

			#Copy Favicons
			echo d | xcopy $destLoc\InstallScripts\favicons\AdC.ico "\\$serverChoiceNexus\$NexusDrive$\Ensequence\iTVManagerUI\favicon.ico" /fYeQV
			#echo d | xcopy $destLoc\InstallScripts\favicons\SA.ico "\\$serverChoiceNexus\$NexusDrive$\Ensequence\SmartAppUI\favicon.ico" /fYeQV
			echo d | xcopy $destLoc\InstallScripts\favicons\WM.ico "\\$serverChoiceNexus\C$\Ensequence\WatermarkUI\favicon.ico" /fYeQV
			If ($resetNexusDB -eq 1) {
				Invoke-Command -Session $mySesNexus1 -scriptblock {
					push-location "C:\Ensequence\InstallScripts\Setups\SetupScripts\"
					invoke-expression -Command ".\Deploy_iTVManagerDataBase.bat"
				}
			}
			if ($resetNexus -eq 1) {
				$moduleName = "Nexus"
				Invoke-Command -Session $mySesNexus1 -scriptblock $resetServer -Args $moduleName
			}

			Remove-PSSession $mySesNexus1
			net use \\$serverChoiceNexus\$NexusDrive$ /delete
			#Write-Output $compChoice
		}
		5 { #Ensequence Streamer
			Write-Output "== Checking Drive $($EinsteinDrive) availability on this $($serverChoiceStreamer) server =="
			##Copy to Remote Server
			net use \\$serverChoiceStreamer\$EinsteinDrive$ /USER:$userName $userPwd
			Write-Output "== %%%778=="

			if ($LASTEXITCODE -ne 0) {
				Write-Output "== Drive $($EinsteinDrive) is not available for installation on this $($serverChoiceStreamer) server =="
				net use \\$serverChoiceStreamer\$EinsteinDrive$ /delete
				exit
			}

			#Write-Output $compChoice
			Write-Output $sourceBld
			$destLoc = "\\$serverChoiceStreamer\C$\Ensequence\"

			#Copy to Remote Server
			if (-not(Test-Path -Path "$($destLoc)\InstallScripts\Setups\"))
			{
				New-Item -Path "$($destLoc)\InstallScripts\Setups\" -type directory -force
			}

			# Copy initial setup for remote server
			if (-not(Test-Path -Path "$($destLoc)\InstallScripts\InitialPS.ps1"))
			{
				echo f | xcopy .\InitialPS.ps1 $destLoc\InstallScripts /fYeQV
			}
			if (-not(Test-Path -Path "$($destLoc)\InstallScripts\Replace-FileString.ps1"))
			{
				echo f | xcopy .\Replace-FileString.ps1 $destLoc\InstallScripts /fYeQV
			}

			initialMe -remoteserverChoice $serverChoiceStreamer -username $userName -password $userPwd

			#Wait for finishing initialMe process including delete the temporary Setups Directory
			start-sleep -Milliseconds 5000
			if((Test-Path $destLoc))
			{
				# Copy msi Release
				echo d | xcopy $sourceBld\EnsequenceStreamerService $destLoc\InstallScripts\Setups\EnsequenceStreamerService /fYeQV
			} else {
				Read-Host '*** Can not see copy files. Check copied $($destLoc) directory '
			}

			$passwd = convertto-securestring -AsPlainText -Force -String $userPwd

			$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName,$passwd

			$mySesStreamer = New-PSSession -computerName $serverChoiceStreamer -credential $cred
			enter-pssession -session $mySesStreamer
			Write-output "enter PSSession on remoted server $($serverChoiceStreamer)"
			#Uninstall Remotely

			Write-Host "Start to Installation on $($serverChoiceStreamer) on $($EinsteinDrive)"

			#$nameModule = "EnsequenceStreamerService"
			Invoke-Command -Session $mySesStreamer -scriptblock $script -Args "EinsteinStreamerService", $serverChoiceStreamer, $EinsteinDrive, $setPlayoutVariable

			#Disable PSRemoting on Remote computer
			Invoke-Command -Session $mySesStreamer -scriptblock {
				Disable-PSRemoting -Force | Out-Null
			}
			# Remove Session
			Remove-PSSession $mySesStreamer | Out-Null
			net use \\$serverChoiceStreamer\$EinsteinDrive$ /delete
		}
	}
} #End of Function InstallMe

#Virtual Main function
If ($ReadConfig) {
	#Automation running script
	# Read config file
	[xml]$ConfigFile = Get-Content ".\Settings.xml"
	# General Variables
	$userName = $ConfigFile.Settings.General.userName
	$userPwd = $ConfigFile.Settings.General.userPwd # For all QA servers
	#$userPwd = "Ensequenc3!" # for Multicast System
	$scriptDir = $ConfigFile.Settings.General.scriptDir


	[int] $installEinstein = $ConfigFile.Settings.Einstein.installPlayout
	[int] $installMulticast = $ConfigFile.Settings.Einstein.installMulticast
	[int] $installNexus = $ConfigFile.Settings.Nexus.installNexus
	[int] $resetEinsteinDB = $ConfigFile.Settings.Einstein.resetEinsteinDB
	[int] $setPlayoutVariable = $ConfigFile.Settings.Einstein.setPlayoutVariable
	[int] $resetEinstein = $ConfigFile.Settings.Nexus.resetEinstein
	[int] $installStreamer = $ConfigFile.Settings.Einstein.installStreamer

	#Einstein Single
	If ($installEinstein -eq 1 ){
		$BLD_NUM = $ConfigFile.Settings.Einstein.BuildEinstein
		if ($BLD_NUM -match [regex]::Escape("Main\")) {
			#Write-output "Catch Main\"
			$bldServer = $ConfigFile.Settings.General.bldQAServer
		} else {
			$bldServer = $ConfigFile.Settings.General.bldReleaseServer
		}
		$sourceBld = $bldServer + "Einstein\" + $BLD_NUM + "\Setups\"
		$serverChoiceEinstein = $ConfigFile.Settings.Einstein.nameEinsteinSingle
		[int] $resetEinsteinDB = $ConfigFile.Settings.Einstein.resetEinsteinDB
		$setPlayoutVariable = $ConfigFile.Settings.Einstein.setPlayoutVariable
		$EinsteinDrive = $ConfigFile.Settings.Einstein.EinsteinDrive
		InstallMe -compChoice 1
	}
	#Einstein Multiple
	If ($installEinstein -eq 2 ){
		$BLD_NUM = $ConfigFile.Settings.Einstein.BuildEinstein
		if ($BLD_NUM -match [regex]::Escape("Main\")) {
			#Write-output "Catch Main\"
			$bldServer = $ConfigFile.Settings.General.bldQAServer
		} else {
			$bldServer = $ConfigFile.Settings.General.bldReleaseServer
		}
		$sourceBld = $bldServer + "Einstein\" + $BLD_NUM + "\Setups\"
		$serverChoiceEnsequencePlayoutWeb = $ConfigFile.Settings.Einstein.nameEinsteinUI
		$serverChoiceEinsteinPlayout = $ConfigFile.Settings.Einstein.nameEinsteinPlayout
		[int] $resetEinsteinDB = $ConfigFile.Settings.Einstein.resetEinsteinDB
		$setPlayoutVariable = $ConfigFile.Settings.Einstein.setPlayoutVariable
		$EinsteinDrive = $ConfigFile.Settings.Einstein.EinsteinDrive
		Write-output "Playout Variable: $($setPlayoutVariable)"
		InstallMe -compChoice 2
	}
	#Multicast
	If ($installMulticast -eq 1 ){
		$BLD_NUM = $ConfigFile.Settings.Einstein.BuildEinstein
		if ($BLD_NUM -match [regex]::Escape("Main\")) {
			$bldServer = $ConfigFile.Settings.General.bldQAServer
			Write-output "Using build from " + $bldServer
		} else {
			$bldServer = $ConfigFile.Settings.General.bldReleaseServer
		}
		$sourceBld = $bldServer + "Einstein\" + $BLD_NUM + "\Setups\"
		$serverChoiceMulticast = $ConfigFile.Settings.Einstein.nameMulticast
		$serverChoicePO = $ConfigFile.Settings.Einstein.nameMulticastPlayout
		$EinsteinDrive = $ConfigFile.Settings.Einstein.EinsteinDrive
		InstallMe -compChoice 3

	}
	#Nexus
	If ($installNexus -eq 1 ){
		$BLD_NUM = $ConfigFile.Settings.Nexus.BuildNexus
		if ($BLD_NUM -match [regex]::Escape("Main\")) {
			#Write-output "Catch Main\"
			$bldServer = $ConfigFile.Settings.General.bldQAServer
		} else {
			$bldServer = $ConfigFile.Settings.General.bldReleaseServer
		}

		$sourceNexusBld = $bldServer + "Nexus\" + $BLD_NUM + "\Setups\"
		$bldServer = $ConfigFile.Settings.General.bldServer
		$serverChoiceNexus = $ConfigFile.Settings.Nexus.nameNexus
		$serverPubEinstein = $ConfigFile.Settings.Nexus.nameEinsteinPublish
		[int] $resetNexusDB = $ConfigFile.Settings.Nexus.resetNexusDB
		$NexusDrive = $ConfigFile.Settings.Nexus.NexusDrive
		[int] $resetNexus = $ConfigFile.Settings.Nexus.resetNexus
		InstallMe -compChoice 4

	}
	#Ensequence Streamer
	If ($installStreamer -eq 1 ){
		$BLD_NUM = $ConfigFile.Settings.Einstein.BuildEinstein
		if ($BLD_NUM -match [regex]::Escape("Main\")) {
			#Write-output "Catch Main\"
			$bldServer = $ConfigFile.Settings.General.bldQAServer
		} else {
			$bldServer = $ConfigFile.Settings.General.bldReleaseServer
		}
		$sourceBld = $bldServer + "Einstein\" + $BLD_NUM + "\Setups\"
		$serverChoiceStreamer = $ConfigFile.Settings.Einstein.nameStreamer
		$EinsteinDrive = $ConfigFile.Settings.Einstein.EinsteinDrive

		InstallMe -compChoice 5
	}
	#Write-output "BldServer is at $($bldServer)"
} else {
	# General Variables
	#$serverChoice=”qaitv25” #this is the name of your server
	$userName = "localhost\Administrator"
	$userPwd = "Ensequenc3" # For all QA servers
	#$userPwd = "Ensequenc3!" # for Multicast System
	#$bldServer ="\\scm\Builds\QA\"
	$bldServer ="\\scm\Builds\QA_Release_Builds\\"
	$scriptDir ="C:\Ensequence\InstallScripts"

	# Interact running script
	Write-Output "1. Install Einstein on single server";
	Write-Output "2. Install Einstein on multi-server";
	Write-Output "3. Install Einstein Multicast Server";
	Write-Output "4. Install Author Nexus SmartApp JAWS";

	[int] $compChoice = Read-Host '*** Enter your choice 1,2 or 3'


	# Get which type of of Software version: Main, Release or Other
	[string] $rlsLoc = Read-Host '*** QA Releases(1), Final QA Release(2), or Other (1, 2, or 3)'

	if ($compChoice -eq 1)
	{
		if ($rlsLoc -eq 1){
			$strBldLoc= $bldServer + "Einstein\Main"
		} elseif ($rlsLoc -eq 2){
			$strBldLoc = $bldServer + "Einstein\Release"
		} else {
			$strBldLoc= $bldServer + "Einstein\Main"
		}
		Get-ChildItem -Force $strBldLoc -Name | sort LastWriteTime -Descending
		$BLD_NUM = Read-Host 'Enter Einstein build you want to install EX: Einstein_Release.2.2.0.15'
		$sourceBld = $strBldLoc + "\" + $BLD_NUM + "\Setups\"
		[string] $serverChoiceEinstein = Read-Host '*** Please enter your Einstein Server host name: '
		[int] $resetEinsteinDB = Read-Host '*** Please enter 0 for NOT reset Einstein DB and 1 for reset Einstein DB : '
		$EinsteinDrive = Read-Host '*** Please specify the Disk Drive that the Einstein build will be installed ex: C, D, G.. : '
		if([System.IO.Directory]::Exists($EinsteinDrive)){
			InstallMe -compChoice 4
		}else {
			Write-Output "Drive $($EinsteinDrive) is not available for installation"
		}
	}
	if ($compChoice -eq 2)
	{
		if ($rlsLoc -eq 1){
			$strBldLoc= $bldServer + "Einstein\Main"
		} elseif ($rlsLoc -eq 2){
			$strBldLoc= $bldServer + "Einstein_Release"
		} else {
			$strBldLoc= $bldServer + "Einstein\Main"
		}
		Get-ChildItem -Force $strBldLoc -Name | sort LastWriteTime -Descending
		$BLD_NUM = Read-Host 'Enter Einstein build you want to install EX: Einstein_Release.2.2.0.15'
		$sourceBld = $strBldLoc + "\" + $BLD_NUM + "\Setups\"
		[string] $serverChoiceEnsequencePlayoutWeb = Read-Host '*** Please enter your Einstein UI/DataService Server host name'
		[string] $serverChoiceEinsteinPlayout = Read-Host '*** Please enter your Einstein Playout Server host name'
		[int] $resetEinsteinDB = Read-Host '*** Please enter 0 for NOT reset Einstein DB and 1 for reset Einstein DB : '
		$EinsteinDrive = Read-Host '*** Please specify the Disk Drive that the Einstein build will be installed ex: C, D, G.. : '
		if([System.IO.Directory]::Exists($EinsteinDrive)){
			InstallMe -compChoice 4
		}else {
			Write-Output "Drive $($EinsteinDrive) is not available for installation"
		}
	}
	if ($compChoice -eq 3)
	{
		if ($rlsLoc -eq 1){
			$strBldLoc= $bldServer + "Einstein\Main"
		} elseif ($rlsLoc -eq 2){
			$strBldLoc= $bldServer + "Einstein\Release"
		} else {
			$strBldLoc= $bldServer + "Einstein\Main"
		}
		Get-ChildItem -Force $strBldLoc -Name | sort LastWriteTime -Descending
		$BLD_NUM = Read-Host 'Enter Einstein build you want to install EX: Einstein_Release.2.2.0.15'
		$sourceBld = $strBldLoc + "\" + $BLD_NUM + "\Setups\"
		[string] $serverChoiceMulticast = Read-Host '*** Please enter your Multicast Server host name: '
		[string] $serverChoicePO = Read-Host '*** Please enter your Einstein Playout Server host name'
		$EinsteinDrive = Read-Host '*** Please specify the Disk Drive that the Einstein build will be installed ex: C, D, G.. : '
		if([System.IO.Directory]::Exists($EinsteinDrive)){
			InstallMe -compChoice 4
		}else {
			Write-Output "Drive $($EinsteinDrive) is not available for installation"
		}
	}
	if ($compChoice -eq 4)
	{
		if($rlsLoc -eq 1) {
			$strBldLoc= $bldServer + "Nexus\Main"
		} elseif ($rlsLoc -eq 2){
			$strBldLoc= $bldServer + "Nexus\Release"
		} else {
			$strBldLoc= $bldServer + "Nexus\Main"
		}
		Get-ChildItem -Force $strBldLoc -Name | sort LastWriteTime -Descending
		$BLD_NUM = Read-Host 'Enter Nexus build you want to install EX: Nexus_Release.1.0.0.15'
		$sourceNexusBld = $strBldLoc + "\" + $BLD_NUM + "\Setups\"
		[string] $serverChoiceNexus = Read-Host '*** Please enter your Nexus Server host name: '
		[string] $serverPubEinstein = Read-Host '*** Please enter your Published Einstein Server host name: '
		[int] $resetNexusDB = Read-Host '*** Please enter 0 for NOT reset Nexus DB and 1 for reset Nexus DB : '
		$NexusDrive = Read-Host '*** Please specify the Disk Drive that the Nexus will be installed ex: C, D, G.. : '
		if([System.IO.Directory]::Exists($NexusDrive)){
			InstallMe -compChoice 4
		}else {
			Write-Output "Drive $($NexusDrive) is not available for installation"
		}
	}
	#Call InstallMe function
	InstallMe -compChoice $compChoice
}#End of If-else read config file
#$servers = *(Read-Host "Enter each IIS (separate withcomma)").split(',') | % {$_.trim()}

# Remove Trusthosts
#Clear-Item -Path WSMan:\localhost\Client\TrustedHosts -Force
#Disable PSRemoting on localhost after done
#Disable-PSRemoting -Force | Out-Null

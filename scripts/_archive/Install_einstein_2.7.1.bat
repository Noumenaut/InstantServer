@echo off

goto check_Permissions

:check_Permissions
    rem  Administrative permissions required. Detecting permissions..
    net session >nul 2>&1
    if %errorlevel% == 0 (

      choco install -y sysinternals
      choco install -y fiddler4
      choco install -y baretail
      rem choco install -y nodejs
      choco install -y curl
      choco install -y notepadplusplus
      choco install -y dotnet3.5
      choco install -y dotnet4.5
      echo create itvuser
      net user itvuser getty123^^^^^^ /add
      echo Add itvuser to the administrators group
      net localgroup administrators itvuser /add
      echo Remove itvuser from the default "users" group
      net localgroup users itvuser /delete

      echo install the SQL server
      C:\installers\en_sql_server_2014_standard_edition_with_service_pack_1_x86_dvd_6669994\setup.exe /ConfigurationFile=C:\scripts\sql_install_config.INI

      echo quicktime silent install is awful, sorry.
      C:\installers\quicktimeinstaller
      echo Install IIS and friends manually in ServerManager until I get Boxstarter working
      servermanager
      pause

      echo 'Installing MPStudio'
      C:\installers\Einstein_2.7.1\NordenMax\MPStudio_Non-Verizon_0-day_Standard\runmefirst.bat
      echo 'Installing PlayoutService'
      msiexec /I c:\installers\Einstein_2.7.1\PlayoutService\playoutservice.msi /qn
      echo 'Installing MPEG Listener'
      msiexec /I c:\installers\Einstein_2.7.1\MPEGListener\mpeglistener.msi /qn
      echo 'Installing Ensequence Streamer'
      msiexec /I c:\installers\Einstein_2.7.1\EnsequenceStreamerService\EnsequenceStreamerService.msi /qn
      echo 'Installing Playout Web'
      msiexec /I c:\installers\Einstein_2.7.1\EnsequencePlayoutWeb\EnsequencePlayoutWeb.msi /qn
      echo 'Installing AdRecognition Service'
      msiexec /I c:\installers\Einstein_2.7.1\AdRecognitionService\AdRecognitionService.msi /qn
      pause

      net start "Ensequence Playout Service"
      net start "Ensequence MPEG Listener"
      net start "Ensequence Ad Recognition Service"

      pause

    ) else (
      echo ######## ########  ########   #######  ########
      echo ##       ##     ## ##     ## ##     ## ##     ##
      echo ##       ##     ## ##     ## ##     ## ##     ##
      echo ######   ########  ########  ##     ## ########
      echo ##       ##   ##   ##   ##   ##     ## ##   ##
      echo ##       ##    ##  ##    ##  ##     ## ##    ##
      echo ######## ##     ## ##     ##  #######  ##     ##
      echo.
      echo -- ADMINISTRATOR PRIVILEGES REQUIRED ------------------
      echo This script must be run as administrator to work.
      echo Right-click on the script icon and select
      echo "Run As Administrator".
      echo -------------------------------------------------------
      echo.
      pause >nul
    )

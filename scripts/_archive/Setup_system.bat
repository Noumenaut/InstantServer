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
      rem create itvuser
      net user itvuser getty123^^^^^^ /add
      REM Add itvuser to the administrators group
      net localgroup administrators itvuser /add
      REM Remove itvuser from the default "users" group
      net localgroup users itvuser /delete

      rem install the SQL server
      C:\installers\en_sql_server_2014_standard_edition_with_service_pack_1_x86_dvd_6669994\setup.exe /ConfigurationFile=C:\scripts\sql_install_config.INI
  
      rem quicktime silent install is horrifyingly unmaintainable, sorry. Best I can do for now
      C:\installers\quicktimeinstaller
      echo Install IIS and friends now before running Install_Einstein
      servermanager
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

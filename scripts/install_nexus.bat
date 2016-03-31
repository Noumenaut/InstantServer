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

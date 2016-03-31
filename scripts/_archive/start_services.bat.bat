@echo off

goto check_Permissions

:check_Permissions
    rem  Administrative permissions required. Detecting permissions..
    net session >nul 2>&1
    if %errorlevel% == 0 (
	  
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

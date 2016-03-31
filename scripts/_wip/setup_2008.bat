@echo off

rem
rem run this script to prepare your Windows2012r2 server for Einstein installation
rem
rem source: Einstein Deployment Guide - Verizon.docx
rem

goto check_Permissions

:check_Permissions
    echo Administrative permissions required. Detecting permissions..
    echo.
    net session >nul 2>&1
    if %errorlevel% == 0 (
      "C:\Windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\ServiceModelReg.exe" -i -x -y
      "C:\Windows\Microsoft.Net\Framework64\v4.0.30319\aspnet_regiis.exe" -ga "NT AUTHORITY\NETWORK SERVICE"
      "C:\Windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\ServiceModelReg.exe" -r -y
      "C:\Windows\Microsoft.NET\Framework\v3.0\Windows Communication Foundation\ServiceModelReg.exe" -ua -y
      dism /Online /Enable-Feature /FeatureName:WCF-HTTP-Activation /All
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
      echo Right-click on cmd.exe from the start menu and select
      echo "Run As Administrator" and re-run this script.
      echo -------------------------------------------------------
      echo.
    )

pause >nul
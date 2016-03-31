@echo off

For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a)

set filename=machine_%mydate%_%mytime%
mkdir %filename%
cd %filename%
copy ..\vagrantfiles\vagrantfile-einstein-test Vagrantfile >nul
echo %filename% created.
vagrant up

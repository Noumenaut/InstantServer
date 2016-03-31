@echo off

cd %1
vagrant destroy -f
cd ..
rmdir %1 /s /q

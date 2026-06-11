@echo off
chcp 65001 >nul
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" "D:\jshERP\installer\setup.iss" > "D:\jshERP\installer\iscc3.log" 2>&1
echo EXIT:%ERRORLEVEL%

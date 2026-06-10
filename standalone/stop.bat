@echo off
chcp 65001 >nul

title MokuERP 单机版停止中...

echo ==========================================
echo    MokuERP 单机版停止脚本
echo ==========================================
echo.

echo [1/3] 正在停止 Java 后端...
taskkill /F /IM java.exe 2>nul
if %errorlevel% equ 0 (
    echo        Java 后端已停止
) else (
    echo        Java 后端未运行或已停止
)
echo.

echo [2/3] 正在停止 MySQL...
taskkill /F /IM mysqld.exe 2>nul
if %errorlevel% equ 0 (
    echo        MySQL 已停止
) else (
    echo        MySQL 未运行或已停止
)
echo.

echo [3/3] 正在停止 Redis...
taskkill /F /IM redis-server.exe 2>nul
if %errorlevel% equ 0 (
    echo        Redis 已停止
) else (
    echo        Redis 未运行或已停止
)
echo.

echo ==========================================
echo    所有服务已停止
echo ==========================================
echo.
pause

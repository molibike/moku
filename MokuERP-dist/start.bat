@echo off
chcp 65001 >nul
title MokuERP 启动脚本
echo ========================================
echo   MokuERP 一键启动脚本
echo ========================================

REM 检查 Java 环境
java -version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到 Java 环境，请先安装 JDK 8 或以上版本。
    echo 下载地址：https://adoptium.net/
    pause
    exit /b 1
)
echo [OK] Java 环境已就绪

REM 启动 Redis（如果未运行）
tasklist | findstr "redis-server.exe" >nul
if errorlevel 1 (
    echo [信息] 正在启动 Redis ...
    start /B "" "%~dp0redis\redis-server.exe" "%~dp0redis\redis.windows.conf" >nul 2>&1
    timeout /t 2 /nobreak >nul
    echo [OK] Redis 已启动
) else (
    echo [OK] Redis 已在运行
)

REM 启动 MokuERP
echo [信息] 正在启动 MokuERP ...
echo [信息] 服务启动后请访问：http://localhost:9999
echo [信息] 默认账号：Moku / 密码：123456
echo [信息] 后台管理员账号：admin / 密码：123456
echo ========================================
java -jar "%~dp0MokuERP.jar" --server.port=9999

pause

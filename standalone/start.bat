@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

title MokuERP 单机版启动中...

:: 设置路径
set "BASE_DIR=%~dp0"
set "JAVA_HOME=D:\MokuERP\tools\jdk8\jdk8u422-b05"
set "MYSQL_DIR=D:\MokuERP\tools\mysql\mysql-5.7.44-winx64"
set "REDIS_DIR=D:\MokuERP\tools\redis"
set "UPLOAD_DIR=D:\MokuERP\upload"
set "TMP_DIR=D:\MokuERP\tmp\tomcat"

:: 添加到 PATH
set "PATH=%JAVA_HOME%\bin;%MYSQL_DIR%\bin;%REDIS_DIR%;%PATH%"

:: 确保目录存在
if not exist "%UPLOAD_DIR%" mkdir "%UPLOAD_DIR%"
if not exist "%TMP_DIR%" mkdir "%TMP_DIR%"

echo ==========================================
echo    MokuERP 单机版启动脚本
echo ==========================================
echo.

:: 启动 MySQL
echo [1/4] 正在检查 MySQL...
tasklist | findstr /i "mysqld.exe" >nul
if %errorlevel% equ 0 (
    echo        MySQL 已运行，跳过启动
) else (
    echo        正在启动 MySQL...
    start "MySQL" /min "cmd.exe" /c ""%MYSQL_DIR%\bin\mysqld.exe" --console --basedir="%MYSQL_DIR%" --datadir=D:\MokuERP\tools\mysql\data >nul 2>&1"
    timeout /t 5 /nobreak >nul
    echo        MySQL 启动完成
)
echo.

:: 启动 Redis
echo [2/4] 正在检查 Redis...
tasklist | findstr /i "redis-server.exe" >nul
if %errorlevel% equ 0 (
    echo        Redis 已运行，跳过启动
) else (
    echo        正在启动 Redis...
    start "Redis" /min "cmd.exe" /c ""%REDIS_DIR%\redis-server.exe" "%REDIS_DIR%\redis.windows.conf" >nul 2>&1"
    timeout /t 3 /nobreak >nul
    echo        Redis 启动完成
)
echo.

:: 启动 Java 后端
echo [3/4] 正在检查 Java 后端...
tasklist | findstr /i "java.exe" >nul
if %errorlevel% equ 0 (
    echo        Java 后端已运行，跳过启动
) else (
    echo        正在启动 Java 后端...
    start "MokuERP Backend" /min "cmd.exe" /c "java -jar -Dfile.encoding=UTF-8 "%BASE_DIR%MokuERP.jar" >"%BASE_DIR%backend.log" 2>&1"
    echo        Java 后端启动中，请等待...
    timeout /t 15 /nobreak >nul
    echo        Java 后端启动完成
)
echo.

:: 打开浏览器
echo [4/4] 正在打开浏览器...
echo        访问地址: http://localhost:9999
timeout /t 2 /nobreak >nul
start "" "http://localhost:9999"
echo.

echo ==========================================
echo    MokuERP 启动完成！
echo    浏览器将自动打开系统
echo    默认账号: admin / 123456
echo    租户账号: Moku / 123456
echo ==========================================
echo.
echo 按任意键关闭本窗口（服务仍在后台运行）...
pause >nul

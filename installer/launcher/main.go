package main

import (
	"fmt"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"time"
	"unsafe"
)

func main() {
	// 隐藏控制台窗口（GUI应用编译开关为 -H=windowsgui）
	hideConsole()

	exe, err := os.Executable()
	if err != nil {
		msgBox("错误", "无法获取程序路径: "+err.Error(), 0x10)
		os.Exit(1)
	}
	baseDir := filepath.Dir(exe)

	// 路径配置
	javaHome := filepath.Join(baseDir, "tools", "jdk8", "jdk8u422-b05")
	mysqlDir := filepath.Join(baseDir, "tools", "mysql", "mysql-5.7.44-winx64")
	redisDir := filepath.Join(baseDir, "tools", "redis")
	jarPath := filepath.Join(baseDir, "MokuERP.jar")
	uploadDir := filepath.Join(baseDir, "upload")
	tmpDir := filepath.Join(baseDir, "tmp", "tomcat")
	dataDir := filepath.Join(baseDir, "tools", "mysql", "data")
	logsDir := filepath.Join(baseDir, "logs")

	os.MkdirAll(uploadDir, 0755)
	os.MkdirAll(tmpDir, 0755)
	os.MkdirAll(logsDir, 0755)

	// 创建 launcher 自身日志，方便排查问题
	launcherLog, _ := os.OpenFile(filepath.Join(logsDir, "launcher.log"), os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
	if launcherLog != nil {
		defer launcherLog.Close()
	}
	log := func(msg string) {
		if launcherLog != nil {
			launcherLog.WriteString(fmt.Sprintf("[%s] %s\n", time.Now().Format("2006-01-02 15:04:05"), msg))
		}
	}

	log("MokuERP 启动中...")
	log(fmt.Sprintf("baseDir=%s", baseDir))
	log(fmt.Sprintf("javaHome=%s", javaHome))
	log(fmt.Sprintf("mysqlDir=%s", mysqlDir))
	log(fmt.Sprintf("redisDir=%s", redisDir))
	log(fmt.Sprintf("jarPath=%s", jarPath))

	// 设置环境变量
	os.Setenv("JAVA_HOME", javaHome)
	os.Setenv("PATH", filepath.Join(javaHome, "bin")+";"+filepath.Join(mysqlDir, "bin")+";"+redisDir+";"+os.Getenv("PATH"))

	// 1. 启动 MySQL
	mysqldPath := filepath.Join(mysqlDir, "bin", "mysqld.exe")
	if !fileExists(mysqldPath) {
		msgBox("错误", "找不到 MySQL 程序:\n"+mysqldPath, 0x10)
		os.Exit(1)
	}
	if !isProcessRunning("mysqld.exe") {
		msgBox("提示", "正在启动 MySQL...", 0x40)
		log("正在启动 MySQL...")
		cmd := exec.Command(mysqldPath,
			"--console",
			"--basedir="+mysqlDir,
			"--datadir="+dataDir)
		cmd.SysProcAttr = &syscall.SysProcAttr{
			HideWindow:    true,
			CreationFlags: syscall.CREATE_NEW_PROCESS_GROUP,
		}
		if err := cmd.Start(); err != nil {
			log("启动 MySQL 失败: " + err.Error())
			msgBox("错误", "启动 MySQL 失败: "+err.Error(), 0x10)
			os.Exit(1)
		}
		log("MySQL 进程已启动")
		time.Sleep(5 * time.Second)
	} else {
		log("MySQL 已在运行")
	}

	// 2. 启动 Redis
	redisPath := filepath.Join(redisDir, "redis-server.exe")
	redisConf := filepath.Join(redisDir, "redis.windows.conf")
	if !fileExists(redisPath) {
		msgBox("错误", "找不到 Redis 程序:\n"+redisPath, 0x10)
		os.Exit(1)
	}
	if !fileExists(redisConf) {
		msgBox("错误", "找不到 Redis 配置文件:\n"+redisConf, 0x10)
		os.Exit(1)
	}
	if !isProcessRunning("redis-server.exe") {
		msgBox("提示", "正在启动 Redis...", 0x40)
		log("正在启动 Redis...")
		cmd := exec.Command(redisPath, redisConf)
		cmd.SysProcAttr = &syscall.SysProcAttr{
			HideWindow:    true,
			CreationFlags: syscall.CREATE_NEW_PROCESS_GROUP,
		}
		if err := cmd.Start(); err != nil {
			log("启动 Redis 失败: " + err.Error())
			msgBox("错误", "启动 Redis 失败: "+err.Error(), 0x10)
			os.Exit(1)
		}
		log("Redis 进程已启动")
		time.Sleep(3 * time.Second)
	} else {
		log("Redis 已在运行")
	}

	// 3. 启动 Java 后端
	javaPath := filepath.Join(javaHome, "bin", "java.exe")
	if !fileExists(javaPath) {
		msgBox("错误", "找不到 Java 程序:\n"+javaPath, 0x10)
		os.Exit(1)
	}
	if !fileExists(jarPath) {
		msgBox("错误", "找不到 JAR 文件:\n"+jarPath, 0x10)
		os.Exit(1)
	}
	if !isProcessRunning("java.exe") {
		msgBox("提示", "正在启动 Java 后端...", 0x40)
		log("正在启动 Java 后端...")
		logFile := filepath.Join(logsDir, "backend.log")
		f, err := os.OpenFile(logFile, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
		if err != nil {
			log("创建日志文件失败: " + err.Error())
			msgBox("错误", "创建日志文件失败: "+err.Error(), 0x10)
			os.Exit(1)
		}
		defer f.Close()

		cmd := exec.Command(javaPath,
			"-jar",
			"-Dfile.encoding=UTF-8",
			"-Dserver.tomcat.basedir="+tmpDir,
			jarPath)
		cmd.SysProcAttr = &syscall.SysProcAttr{
			HideWindow:    true,
			CreationFlags: syscall.CREATE_NEW_PROCESS_GROUP,
		}
		cmd.Stdout = f
		cmd.Stderr = f
		if err := cmd.Start(); err != nil {
			log("启动 Java 后端失败: " + err.Error())
			msgBox("错误", "启动 Java 后端失败: "+err.Error(), 0x10)
			os.Exit(1)
		}
		log("Java 后端进程已启动")
		msgBox("提示", "Java 后端启动中，请等待约 30 秒...", 0x40)
		time.Sleep(20 * time.Second)
	} else {
		log("Java 后端已在运行")
	}

	// 4. 等待服务就绪
	msgBox("提示", "正在检测服务状态...", 0x40)
	log("正在检测服务状态...")
	if !waitForPort("localhost:9999", 60*time.Second) {
		log("服务启动超时")
		msgBox("错误", "服务启动超时，请检查日志:\n"+filepath.Join(logsDir, "backend.log"), 0x10)
		os.Exit(1)
	}
	log("服务已就绪")

	// 5. 打开浏览器
	log("正在打开浏览器...")
	exec.Command("cmd", "/c", "start", "", "http://localhost:9999").Start()

	// 6. 显示完成提示
	msgBox("MokuERP 启动成功",
		"MokuERP 已启动完成！\n\n浏览器将自动打开系统。\n\n访问地址: http://localhost:9999\n默认账号: admin / 123456\n租户: Moku\n\n服务已在后台运行，可以关闭此窗口。",
		0x40)
	log("启动完成")
}

func hideConsole() {
	kernel32 := syscall.NewLazyDLL("kernel32.dll")
	getConsoleWindow := kernel32.NewProc("GetConsoleWindow")
	showWindow := syscall.NewLazyDLL("user32.dll").NewProc("ShowWindow")
	hwnd, _, _ := getConsoleWindow.Call()
	if hwnd != 0 {
		showWindow.Call(hwnd, 0) // SW_HIDE
	}
}

func fileExists(path string) bool {
	_, err := os.Stat(path)
	return err == nil
}

func isProcessRunning(name string) bool {
	cmd := exec.Command("tasklist", "/FI", "IMAGENAME eq "+name)
	out, err := cmd.Output()
	if err != nil {
		return false
	}
	return strings.Contains(string(out), name)
}

func waitForPort(address string, timeout time.Duration) bool {
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		conn, err := net.DialTimeout("tcp", address, 2*time.Second)
		if err == nil {
			conn.Close()
			return true
		}
		time.Sleep(1 * time.Second)
	}
	return false
}

func msgBox(title, text string, flags uintptr) {
	user32 := syscall.NewLazyDLL("user32.dll")
	messageBoxW := user32.NewProc("MessageBoxW")
	messageBoxW.Call(0,
		uintptr(unsafe.Pointer(syscall.StringToUTF16Ptr(text))),
		uintptr(unsafe.Pointer(syscall.StringToUTF16Ptr(title))),
		flags)
}

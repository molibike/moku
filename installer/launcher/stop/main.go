package main

import (
	"os/exec"
	"syscall"
	"unsafe"
)

func main() {
	hideConsole()

	stopProcess("java.exe", "Java 后端")
	stopProcess("mysqld.exe", "MySQL")
	stopProcess("redis-server.exe", "Redis")

	msgBox("MokuERP 已停止", "所有服务已停止。", 0x40)
}

func hideConsole() {
	kernel32 := syscall.NewLazyDLL("kernel32.dll")
	getConsoleWindow := kernel32.NewProc("GetConsoleWindow")
	showWindow := syscall.NewLazyDLL("user32.dll").NewProc("ShowWindow")
	hwnd, _, _ := getConsoleWindow.Call()
	if hwnd != 0 {
		showWindow.Call(hwnd, 0)
	}
}

func stopProcess(name, label string) {
	exec.Command("taskkill", "/F", "/IM", name).Run()
}

func msgBox(title, text string, flags uintptr) {
	user32 := syscall.NewLazyDLL("user32.dll")
	messageBoxW := user32.NewProc("MessageBoxW")
	messageBoxW.Call(0,
		uintptr(unsafe.Pointer(syscall.StringToUTF16Ptr(text))),
		uintptr(unsafe.Pointer(syscall.StringToUTF16Ptr(title))),
		flags)
}

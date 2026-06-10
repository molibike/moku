============================================
  MokuERP 单机版客户端安装包
============================================

一、目录说明
  MokuERP.jar        - 整合后的后端服务包（包含前端页面）
  start.bat         - 一键启动脚本（启动 MySQL + Redis + Java 后端 + 浏览器）
  stop.bat          - 一键停止脚本（停止所有服务）
  backend.log       - 后端运行日志（自动生成）
  backend.err.log   - 后端错误日志（自动生成）

二、使用说明
  1. 确保以下服务未被占用：
     - MySQL 端口 3306
     - Redis 端口 6379
     - Java 后端端口 9999

  2. 双击运行 start.bat
     - 脚本会自动检测并启动 MySQL、Redis
     - 启动 Java 后端服务
     - 自动打开浏览器访问 http://localhost:9999

  3. 系统默认登录信息
     - 租户：Moku
     - 账号：admin
     - 密码：123456

  4. 如需停止服务，双击运行 stop.bat

三、注意事项
  - 首次启动时，MySQL 数据已包含演示数据
  - 文件上传目录：D:\MokuERP\upload
  - 请勿删除 tools 目录下的 MySQL/Redis/JDK 运行环境

四、技术环境
  - JDK 1.8
  - MySQL 5.7
  - Redis 6.2
  - Spring Boot 2.0
  - Vue 2.6 + Ant Design Vue

============================================

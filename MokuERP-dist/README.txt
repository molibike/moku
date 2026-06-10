====================================
  MokuERP 分发包使用说明
====================================

一、环境要求
------------------------------------
1. JDK 8 或以上版本
   - 请确保 java 命令可用
   - 下载地址：https://adoptium.net/

2. MySQL 5.7 或以上版本
   - 需要创建名为 "moku_erp" 的数据库
   - 导入 jsh_erp.sql 初始化数据
   - 默认使用 root/空密码 连接（可在配置中修改）

二、数据库初始化
------------------------------------
1. 启动 MySQL 服务
2. 创建数据库：
   mysql -u root -e "CREATE DATABASE IF NOT EXISTS moku_erp DEFAULT CHARSET utf8;"
3. 导入数据：
   mysql -u root moku_erp < jsh_erp.sql

三、启动方式
------------------------------------
直接双击运行 start.bat

服务启动后访问：
  前台：http://localhost:9999
  账号：Moku / 密码：123456

  后台管理员：admin / 密码：123456

四、目录说明
------------------------------------
  MokuERP.jar     Spring Boot 可执行 JAR（包含前后端）
  jsh_erp.sql     数据库初始化脚本
  redis/          Redis 服务（随 start.bat 自动启动）
  start.bat       一键启动脚本

五、常见问题
------------------------------------
1. 端口冲突：若 9999 或 6379 被占用，请修改配置文件
2. 数据库连接失败：检查 MySQL 是否启动，以及 root 密码是否正确
3. 如需修改数据库配置，请解压 MokuERP.jar 后修改 BOOT-INF/classes/application.properties

====================================

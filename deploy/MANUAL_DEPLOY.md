# MokuERP 手动部署指南

## 服务器信息
- **IP地址**: 8.138.34.56
- **用户名**: root
- **密码**: molI26,.

## 已完成的准备工作
✅ 后端JAR包已打包: `MokuERP-boot/target/MokuERP.jar`
✅ 前端已构建: `MokuERP-web/dist/`
✅ 配置文件已修改为Linux路径
✅ 部署脚本已创建

## 部署步骤

### 第一步：连接到服务器
```bash
ssh root@8.138.34.56
# 输入密码: molI26,.
```

### 第二步：在服务器上安装基础环境
连接成功后，依次执行以下命令：

```bash
# 1. 更新系统
yum update -y

# 2. 安装基础工具
yum install -y wget vim curl net-tools telnet

# 3. 安装 JDK 1.8
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
java -version

# 4. 安装 MySQL 5.7
wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
rpm -ivh mysql57-community-release-el7-11.noarch.rpm
yum install -y mysql-server
systemctl start mysqld
systemctl enable mysqld

# 获取MySQL临时密码
TEMP_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | tail -1 | awk '{print $NF}')
echo "MySQL临时密码: $TEMP_PASSWORD"

# 修改MySQL密码
mysql -u root -p"$TEMP_PASSWORD" --connect-expired-password -e "SET GLOBAL validate_password_policy=LOW;"
mysql -u root -p"$TEMP_PASSWORD" --connect-expired-password -e "SET GLOBAL validate_password_length=6;"
mysql -u root -p"$TEMP_PASSWORD" --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'molI26,.';"

# 5. 安装 Redis
yum install -y epel-release
yum install -y redis
systemctl start redis
systemctl enable redis

# 6. 安装 Nginx
yum install -y nginx
systemctl start nginx
systemctl enable nginx

# 7. 创建应用目录
mkdir -p /opt/mokuerp
mkdir -p /data/mokuerp/upload
mkdir -p /data/mokuerp/tmp
mkdir -p /usr/share/nginx/html/mokuerp

# 8. 配置防火墙
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=22/tcp
firewall-cmd --reload
```

### 第三步：从本地上传文件到服务器
在本地Windows PowerShell中执行：

```powershell
# 进入项目目录
cd d:\jshERP

# 上传后端JAR包
scp MokuERP-boot/target/MokuERP.jar root@8.138.34.56:/opt/mokuerp/

# 上传前端文件
scp -r MokuERP-web/dist/* root@8.138.34.56:/usr/share/nginx/html/mokuerp/

# 上传配置文件
scp deploy/nginx.conf root@8.138.34.56:/root/
scp deploy/mokuerp.service root@8.138.34.56:/root/
scp MokuERP-boot/docs/jsh_erp.sql root@8.138.34.56:/root/
```

### 第四步：在服务器上初始化数据库
```bash
# 创建数据库
mysql -u root -p'molI26,.' -e "CREATE DATABASE moku_erp CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"

# 导入数据
mysql -u root -p'molI26,.' moku_erp < /root/jsh_erp.sql
```

### 第五步：配置和启动服务
```bash
# 1. 配置 Nginx
cp /root/nginx.conf /etc/nginx/conf.d/mokuerp.conf
# 修改nginx.conf中的server_name为你的域名或IP
sed -i 's/localhost/8.138.34.56/g' /etc/nginx/conf.d/mokuerp.conf
systemctl restart nginx

# 2. 配置 systemd 服务
cp /root/mokuerp.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable mokuerp
systemctl start mokuerp

# 3. 检查服务状态
systemctl status mokuerp
systemctl status nginx
systemctl status mysql
systemctl status redis
```

### 第六步：验证部署
在浏览器中访问: http://8.138.34.56

默认登录信息:
- 租户: Moku
- 账号: admin
- 密码: 123456

## 故障排查

### 查看后端日志
```bash
journalctl -u mokuerp -f
```

### 查看Nginx日志
```bash
tail -f /var/log/nginx/error.log
```

### 查看MySQL日志
```bash
tail -f /var/log/mysqld.log
```

### 重启服务
```bash
systemctl restart mokuerp
systemctl restart nginx
```

## 注意事项
1. 确保服务器防火墙已开放80端口
2. MySQL和Redis不要对外网开放
3. 生产环境建议修改默认密码
4. 建议配置定期数据库备份

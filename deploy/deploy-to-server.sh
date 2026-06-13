#!/bin/bash
# MokuERP 自动化部署脚本
# 在服务器上运行此脚本完成部署

set -e

echo "========================================="
echo "  MokuERP 自动化部署"
echo "========================================="

# 配置变量
MYSQL_ROOT_PASSWORD="molI26,."
MYSQL_DATABASE="moku_erp"
MYSQL_USER="root"
SERVER_IP="8.138.34.56"

# 检测操作系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    echo "无法检测操作系统版本"
    exit 1
fi

echo "检测到操作系统: $OS $VERSION"

# 安装基础工具
echo "步骤 1/10: 安装基础工具..."
if [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
    yum update -y
    yum install -y wget vim curl net-tools telnet
elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    apt update -y
    apt install -y wget vim curl net-tools telnet
fi

# 安装 JDK 1.8
echo "步骤 2/10: 安装 JDK 1.8..."
if ! command -v java &> /dev/null; then
    if [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
        yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
    elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        apt install -y openjdk-8-jdk
    fi
fi
java -version

# 安装 MySQL 5.7
echo "步骤 3/10: 安装 MySQL 5.7..."
if ! command -v mysql &> /dev/null; then
    if [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
        wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
        rpm -ivh mysql57-community-release-el7-11.noarch.rpm
        yum install -y mysql-server
        systemctl start mysqld
        systemctl enable mysqld
        # 获取临时密码
        TEMP_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | tail -1 | awk '{print $NF}')
        echo "MySQL 临时密码: $TEMP_PASSWORD"
        # 修改密码策略
        mysql -u root -p"$TEMP_PASSWORD" --connect-expired-password -e "SET GLOBAL validate_password_policy=LOW;"
        mysql -u root -p"$TEMP_PASSWORD" --connect-expired-password -e "SET GLOBAL validate_password_length=6;"
        mysql -u root -p"$TEMP_PASSWORD" --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
    elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        apt install -y mysql-server-5.7
        systemctl start mysql
        systemctl enable mysql
        mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';"
    fi
fi

# 安装 Redis
echo "步骤 4/10: 安装 Redis..."
if ! command -v redis-server &> /dev/null; then
    if [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
        yum install -y epel-release
        yum install -y redis
    elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        apt install -y redis-server
    fi
    systemctl start redis
    systemctl enable redis
fi

# 安装 Nginx
echo "步骤 5/10: 安装 Nginx..."
if ! command -v nginx &> /dev/null; then
    if [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
        yum install -y nginx
    elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        apt install -y nginx
    fi
    systemctl start nginx
    systemctl enable nginx
fi

# 创建目录
echo "步骤 6/10: 创建应用目录..."
mkdir -p /opt/mokuerp
mkdir -p /data/mokuerp/upload
mkdir -p /data/mokuerp/tmp
mkdir -p /usr/share/nginx/html/mokuerp

# 初始化数据库
echo "步骤 7/10: 初始化数据库..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"

# 检查SQL文件是否存在
if [ -f "/root/jsh_erp.sql" ]; then
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" $MYSQL_DATABASE < /root/jsh_erp.sql
    echo "数据库初始化完成"
else
    echo "警告: 未找到 /root/jsh_erp.sql 文件，请手动导入数据库"
fi

# 配置防火墙
echo "步骤 8/10: 配置防火墙..."
if command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --permanent --add-port=443/tcp
    firewall-cmd --permanent --add-port=22/tcp
    firewall-cmd --reload
elif command -v ufw &> /dev/null; then
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 22/tcp
    ufw --force enable
fi

# 检查文件是否存在
echo "步骤 9/10: 检查部署文件..."
if [ ! -f "/opt/mokuerp/MokuERP.jar" ]; then
    echo "错误: 未找到 /opt/mokuerp/MokuERP.jar，请先上传后端JAR包"
    exit 1
fi

if [ ! -d "/usr/share/nginx/html/mokuerp" ] || [ -z "$(ls -A /usr/share/nginx/html/mokuerp)" ]; then
    echo "错误: 未找到前端文件，请先上传前端dist目录内容到 /usr/share/nginx/html/mokuerp/"
    exit 1
fi

# 配置和启动服务
echo "步骤 10/10: 配置和启动服务..."

# 配置 Nginx
if [ -f "/root/nginx.conf" ]; then
    cp /root/nginx.conf /etc/nginx/conf.d/mokuerp.conf
    # 替换服务器IP
    sed -i "s/localhost/$SERVER_IP/g" /etc/nginx/conf.d/mokuerp.conf
    systemctl restart nginx
else
    echo "警告: 未找到 /root/nginx.conf，请手动配置Nginx"
fi

# 配置 systemd 服务
if [ -f "/root/mokuerp.service" ]; then
    cp /root/mokuerp.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable mokuerp
    systemctl start mokuerp
else
    echo "警告: 未找到 /root/mokuerp.service，请手动配置服务"
fi

echo ""
echo "========================================="
echo "  部署完成！"
echo "========================================="
echo ""
echo "访问地址: http://$SERVER_IP"
echo "默认账号: 租户 Moku, 账号 admin, 密码 123456"
echo ""
echo "检查服务状态:"
echo "  systemctl status mokuerp"
echo "  systemctl status nginx"
echo "  systemctl status mysql"
echo "  systemctl status redis"
echo ""

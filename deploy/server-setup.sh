#!/bin/bash
# MokuERP 服务器部署脚本
# 适用于 CentOS 7.9 / Ubuntu 20.04+
# 使用方法: bash server-setup.sh

set -e

echo "========================================="
echo "  MokuERP 服务器部署脚本"
echo "========================================="

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
install_base_tools() {
    echo "安装基础工具..."
    if [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
        yum update -y
        yum install -y wget vim curl net-tools telnet
    elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        apt update -y
        apt install -y wget vim curl net-tools telnet
    fi
}

# 安装 JDK 1.8
install_jdk() {
    echo "检查 JDK..."
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
        echo "已安装 JDK: $JAVA_VERSION"
    else
        echo "安装 JDK 1.8..."
        if [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
            yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
        elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
            apt install -y openjdk-8-jdk
        fi
    fi
}

# 安装 MySQL 5.7
install_mysql() {
    echo "检查 MySQL..."
    if command -v mysql &> /dev/null; then
        MYSQL_VERSION=$(mysql --version | awk '{print $5}')
        echo "已安装 MySQL: $MYSQL_VERSION"
    else
        echo "安装 MySQL 5.7..."
        if [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
            # 下载 MySQL 5.7 仓库
            wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
            rpm -ivh mysql57-community-release-el7-11.noarch.rpm
            yum install -y mysql-server
            # 启动 MySQL
            systemctl start mysqld
            systemctl enable mysqld
            # 获取临时密码
            TEMP_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | tail -1 | awk '{print $NF}')
            echo "MySQL 临时密码: $TEMP_PASSWORD"
        elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
            apt install -y mysql-server-5.7
            systemctl start mysql
            systemctl enable mysql
        fi
    fi
}

# 安装 Redis
install_redis() {
    echo "检查 Redis..."
    if command -v redis-server &> /dev/null; then
        REDIS_VERSION=$(redis-server --version | awk '{print $3}')
        echo "已安装 Redis: $REDIS_VERSION"
    else
        echo "安装 Redis..."
        if [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
            yum install -y epel-release
            yum install -y redis
        elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
            apt install -y redis-server
        fi
        systemctl start redis
        systemctl enable redis
    fi
}

# 安装 Nginx
install_nginx() {
    echo "检查 Nginx..."
    if command -v nginx &> /dev/null; then
        NGINX_VERSION=$(nginx -v 2>&1 | awk -F '/' '{print $2}')
        echo "已安装 Nginx: $NGINX_VERSION"
    else
        echo "安装 Nginx..."
        if [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
            yum install -y nginx
        elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
            apt install -y nginx
        fi
        systemctl start nginx
        systemctl enable nginx
    fi
}

# 创建目录
create_directories() {
    echo "创建应用目录..."
    mkdir -p /opt/mokuerp
    mkdir -p /data/mokuerp/upload
    mkdir -p /data/mokuerp/tmp
    mkdir -p /usr/share/nginx/html/mokuerp
}

# 配置防火墙
configure_firewall() {
    echo "配置防火墙..."
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
}

# 主函数
main() {
    install_base_tools
    install_jdk
    install_mysql
    install_redis
    install_nginx
    create_directories
    configure_firewall
    
    echo ""
    echo "========================================="
    echo "  基础环境安装完成！"
    echo "========================================="
    echo ""
    echo "接下来的步骤："
    echo "1. 初始化数据库: mysql -u root -p < jsh_erp.sql"
    echo "2. 上传后端 JAR 包到 /opt/mokuerp/"
    echo "3. 上传前端 dist 目录到 /usr/share/nginx/html/mokuerp/"
    echo "4. 配置 Nginx: cp nginx.conf /etc/nginx/conf.d/mokuerp.conf"
    echo "5. 启动后端服务: systemctl start mokuerp"
    echo "6. 重启 Nginx: systemctl restart nginx"
    echo ""
}

main

#!/bin/bash
# 上传文件到服务器

SERVER="root@8.138.34.56"
PASSWORD="molI26,."

echo "开始上传文件到服务器..."

# 使用 scp 上传文件
# 注意: 需要手动输入密码或配置SSH密钥

# 上传后端JAR包
echo "上传后端JAR包..."
scp MokuERP-boot/target/MokuERP.jar $SERVER:/opt/mokuerp/

# 上传前端文件
echo "上传前端文件..."
scp -r MokuERP-web/dist/* $SERVER:/usr/share/nginx/html/mokuerp/

# 上传配置文件
echo "上传配置文件..."
scp deploy/nginx.conf $SERVER:/root/
scp deploy/mokuerp.service $SERVER:/root/
scp deploy/deploy-to-server.sh $SERVER:/root/
scp MokuERP-boot/docs/jsh_erp.sql $SERVER:/root/

echo "文件上传完成！"
echo "请在服务器上运行: bash /root/deploy-to-server.sh"

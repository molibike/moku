# MokuERP 前后端分离部署指南

## 一、环境要求

| 组件 | 版本要求 |
|------|----------|
| JDK | 1.8 |
| MySQL | 5.7 |
| Redis | 6.2+ |
| Nginx | 1.12+ |
| Node.js | 16.x（仅构建前端时需要） |

## 二、数据库初始化

```bash
# 登录 MySQL
mysql -u root -p

# 创建数据库
CREATE DATABASE moku_erp CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

# 导入初始数据
USE moku_erp;
SOURCE /path/to/jshERP/MokuERP-boot/docs/jsh_erp.sql;
```

## 三、后端部署

### 3.1 修改配置文件

编辑 `MokuERP-boot/src/main/resources/application.properties`：

```properties
# 数据库连接
spring.datasource.url=jdbc:mysql://127.0.0.1:3306/moku_erp?useUnicode=true&characterEncoding=utf8&useCursorFetch=true&defaultFetchSize=500&allowMultiQueries=true&rewriteBatchedStatements=true&useSSL=false
spring.datasource.username=root
spring.datasource.password=你的密码

# Redis
spring.redis.host=127.0.0.1
spring.redis.port=6379
spring.redis.password=你的Redis密码（无则留空）

# 文件上传目录（Linux 生产环境建议改为绝对路径）
file.path=/data/mokuerp/upload
server.tomcat.basedir=/data/mokuerp/tmp
```

### 3.2 打包

```bash
cd MokuERP-boot
mvn clean package -DskipTests
```

产物：`target/MokuERP.jar`

### 3.3 启动

**方式一：直接启动**
```bash
java -Xms1000m -Xmx2000m -jar MokuERP.jar
```

**方式二：systemd 服务（推荐 Linux 生产环境）**

```bash
# 复制服务文件
sudo cp deploy/mokuerp.service /etc/systemd/system/

# 创建目录
sudo mkdir -p /opt/mokuerp
sudo cp MokuERP-boot/target/MokuERP.jar /opt/mokuerp/
sudo mkdir -p /data/mokuerp/upload /data/mokuerp/tmp

# 启动服务
sudo systemctl daemon-reload
sudo systemctl enable mokuerp
sudo systemctl start mokuerp
```

## 四、前端部署

### 4.1 构建

```bash
cd MokuERP-web
npm install
npm run build
```

产物：`dist/` 目录

> 注：`public/index.html` 中已配置 `window._CONFIG['domianURL'] = '/api'`，所有 API 请求会自动加上 `/api` 前缀。

### 4.2 部署到 Nginx

将 `dist/` 目录上传到服务器的 `/usr/share/nginx/html/mokuerp/`：

```bash
sudo mkdir -p /usr/share/nginx/html/mokuerp
sudo cp -r MokuERP-web/dist/* /usr/share/nginx/html/mokuerp/
```

### 4.3 Nginx 配置

将 `deploy/nginx.conf` 复制到 Nginx 配置目录（如 `/etc/nginx/conf.d/mokuerp.conf`），然后重载：

```bash
sudo nginx -s reload
```

**Nginx 核心逻辑说明：**
- `location /`：服务前端静态资源，支持 Vue Router history 模式
- `location /api/`：将 `/api/xxx` 反向代理到后端 `http://127.0.0.1:9999/xxx`（自动去掉 `/api` 前缀）

## 五、验证部署

1. 确保 MySQL、Redis、后端服务、Nginx 均已启动
2. 浏览器访问 `http://your-domain.com`
3. 默认账号：租户 `Moku`，账号 `admin`，密码 `123456`

## 六、默认端口

| 服务 | 端口 | 说明 |
|------|------|------|
| Nginx | 80 | 对外访问入口 |
| Spring Boot | 9999 | 内部 API 服务（不对外暴露） |
| MySQL | 3306 | 数据库 |
| Redis | 6379 | 缓存 |

# build stage
# 第一条指令必须为FROM 指令，从node@18拉取镜像并作为构建阶段
FROM node:18-alpine3.18 as build

# 指定工作目录，后续的命令将在该工作目录下执行
WORKDIR /app

# 复制当前的开发工作区中的package.json到容器/app目录下
COPY package.json .

# 切换为taobao镜像
RUN npm config set registry https://registry.npmmirror.com

# 执行npm install 下载依赖
RUN npm install

# 复制当前的开发工作区的其他源代码文件到容器/app目录下
COPY . .

# 执行npm打包构建脚本
RUN npm run build

# deploy-stage
FROM nginx:stable-alpine as deploy

# 从构建环境中复制构建结果到 Nginx 的静态文件目录
COPY --from=build /app/dist /usr/share/nginx/html

# 复制本地工作区的nginx.conf 文件
COPY nginx.conf  /etc/nginx/conf.d/default.conf 

# 暴露80端口和443端口 
EXPOSE 80
EXPOSE 443

# 创建nginx配置目录存放ssl文件并启动nginx
ENTRYPOINT ["sh", "-c","mkdir -p /opt/docker/nginx && nginx -g 'daemon off;'"]




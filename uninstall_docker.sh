#!/bin/bash

# 停止所有正在运行的Docker容器
docker stop $(docker ps -aq)

# 删除所有Docker容器
docker rm $(docker ps -aq)

# 删除所有Docker映像
docker rmi $(docker images -q)

# 删除Docker网络
docker network prune -f

# 删除Docker卷
docker volume prune -f

# 卸载Docker Engine
if [ -x "$(command -v apt-get)" ]; then
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
elif [ -x "$(command -v yum)" ]; then
    sudo yum remove -y docker-ce docker-ce-cli containerd.io
elif [ -x "$(command -v dnf)" ]; then
    sudo dnf remove -y docker-ce docker-ce-cli containerd.io
elif [ -x "$(command -v zypper)" ]; then
    sudo zypper remove -y docker-ce docker-ce-cli containerd.io
elif [ -x "$(command -v apk)" ]; then
    sudo apk del -y docker
else
    echo "无法确定操作系统的包管理器"
    exit 1
fi

# 卸载Docker Compose
sudo rm /usr/local/bin/docker-compose
# 删除Docker Compose相关的文档和配置文件
sudo rm -rf /etc/docker/compose
# 检查Docker是否卸载完成
docker_version=$(docker --version)
docker_compose_version=$(docker-compose --version)

if [ -z "$docker_version" ] && [ -z "$docker_compose_version" ]; then
    echo "已成功卸载Docker和Docker Compose"
else
    echo "卸载Docker和Docker Compose未成功，请手动确认"
fi
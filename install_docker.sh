#!/bin/bash

# 检查操作系统类型
OS_TYPE=$(uname -s)
if [ ${OS_TYPE} != "Linux" ]; then
  echo "仅支持Linux系统"
  exit 1
fi

# 检查发行版本
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=${ID}
  VERSION=${VERSION_ID}
else
  echo "未知的发行版本"
  exit 1
fi

# 检查是否有root权限
if [ "${EUID}" -ne 0 ]; then
  echo "请使用root权限执行此脚本"
  exit 1
fi

# 检查是否存在sudo命令，如果不存在则安装sudo
if ! command -v sudo &> /dev/null; then
  echo "未检测到sudo命令，正在安装sudo..."
  if [ ${OS} == "ubuntu" ] || [ ${OS} == "debian" ]; then
    apt-get update
    apt-get install -y sudo
  elif [ ${OS} == "centos" ]; then
    yum update
    yum install -y sudo
  fi

  if ! command -v sudo &> /dev/null; then
    echo "无法安装sudo，请手动安装后再继续执行"
    exit 1
  fi

  echo "sudo安装成功"
fi

# 检查Docker是否已安装
echo "检查Docker是否已安装..."
if ! command -v docker &> /dev/null; then
  echo "未检测到Docker，开始安装Docker..."
  if [ ${OS} == "ubuntu" ] || [ ${OS} == "debian" ]; then
    if ! command -v curl &> /dev/null; then
      echo "未检测到curl，正在安装curl..."
      sudo apt-get update
      sudo apt-get install -y curl
    fi
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
  elif [ ${OS} == "centos" ]; then
    if ! command -v yum-utils &> /dev/null; then
      echo "未检测到yum-utils，正在安装yum-utils..."
      sudo yum install -y yum-utils
    fi
    sudo yum install -y docker
    sudo systemctl start docker
  fi

  if ! command -v docker &> /dev/null; then
    echo "Docker安装失败"
    exit 1
  fi

  echo "Docker安装成功"
else
  echo "Docker已经安装"
fi

# 检查Docker-compose是否已安装
echo "检查Docker-compose是否已安装..."
if ! command -v docker-compose &> /dev/null; then
  echo "未检测到Docker-compose，开始安装Docker-compose..."
  if [ ${OS} == "ubuntu" ] || [ ${OS} == "debian" ]; then
    if ! command -v curl &> /dev/null; then
      echo "未检测到curl，正在安装curl..."
      sudo apt-get update
      sudo apt-get install -y curl
    fi
    LATEST_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "tag_name" | cut -d '"' -f 4)
    curl -L "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  elif [ ${OS} == "centos" ]; then
    if ! command -v curl &> /dev/null; then
      echo "未检测到curl，正在安装curl..."
      sudo yum install -y curl
    fi
    LATEST_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "tag_name" | cut -d '"' -f 4)
    curl -L "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  fi

  if ! command -v docker-compose &> /dev/null; then
    echo "Docker-compose安装失败"
    exit 1
  fi

  echo "Docker-compose安装成功"
else
  echo "Docker-compose已经安装"
fi
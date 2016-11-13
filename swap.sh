#!  /bin/bash

# Notice: This script only support Ubuntu 16.04
# Author: Jack, Website: qiaohong.org

# 出错即退出脚本
set -e

function add_swap() {
  # 功能： 为系统添加指定大小的交换空间
  # 参数： $1： 交换空间的大小，以 M、G 为单位
  # 返回值： 无

  # 生成指定大小的交换文件
  sudo fallocate -l $1 /swapfile

  # 限定权限为 root 读写
  sudo chmod 600 /swapfile

  # 标记为 swap 文件
  sudo mkswap /swapfile >/dev/null

  # 使交换文件生效
  sudo swapon /swapfile >/dev/null

  # 备份原配置
  sudo cp /etc/fstab /etc/fstab.bak
  # 持久化，将交换文件的信息添加到系统配置
  sudo echo '/swapfile none swap sw 0 0' >> /etc/fstab


  # 备份原配置
  sudo cp /etc/fstab /etc/sysctl.conf.bak
  # 系统调优
  sudo echo 'vm.swappiness=10' >> /etc/sysctl.conf
  sudo echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.conf
}

function restore() {
  # 恢复愿配置
  sudo mv /etc/fstab.bak /etc/fstab
  sudo cp /etc/fstab /etc/sysctl.conf.bak

  # 禁用交换文件
  sudo swapoff /swapfile

  # 删除交换文件
  sudo rm -rf /swapfile
}

if [[ $1 = "add" ]]; then
  add_swap $2
elif [[ $1 = "restore" ]]; then
  restore
else
  echo "
  usage:
    add [size]
            add swap space as your input size. Unit: M, G
    restore
            remove swap file, back to your origin setting.
  "
fi

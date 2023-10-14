#!/bin/bash
apt update && apt install -y openssh-server systemctl wget curl vim nano screen unzip
rm -rf /root/sing-box/
mkdir /root/sing-box/ && cd /root/sing-box/
wget https://github.sock.cf/SagerNet/sing-box/releases/download/v1.5.3/sing-box-1.5.3-linux-amd64.tar.gz
tar -xvf sing-box-*.tar.gz
cp ./sing-box-*/sing-box /root/sing-box/sing-box
chmod +x /root/sing-box/sing-box
rm -rf /root/sing-box/sing-box-*
wget -O /root/sing-box/config.json https://github.sock.cf/ahhfzwl/sing-box/blob/dev-next/config.json
wget -O /root/sing-box/systemctl.sh https://github.sock.cf/ahhfzwl/sing-box/blob/dev-next/systemctl.sh
wget -O /etc/systemd/system/sing-box.service https://github.sock.cf/ahhfzwl/sing-box/blob/dev-next/sing-box.service
systemctl restart sing-box-warp # 重启服务
systemctl enable sing-box-warp # 开机启动

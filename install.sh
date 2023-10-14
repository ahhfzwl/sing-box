#!/bin/bash -e
apt update && apt install -y openssh-server systemctl wget curl vim nano screen unzip
mkdir /root/sing-box/ && cd /root/sing-box/
wget https://github.sock.cf/SagerNet/sing-box/releases/download/v1.5.3/sing-box-1.5.3-linux-amd64.tar.gz
tar -xvf sing-box-*.tar.gz
cp ./sing-box-*/sing-box /root/sing-box/
rm -rf /root/sing-box/sing-box-*
chmod +x /root/sing-box/sing-box
wget -O /root/sing-box/config.json https://raw.sock.cf/ahhfzwl/sing-box/dev-next/config.json
wget -O /root/sing-box/systemctl.sh https://raw.sock.cf/ahhfzwl/sing-box/dev-next/systemctl.sh
wget -O /etc/systemd/system/sing-box.service https://raw.sock.cf/ahhfzwl/sing-box/dev-next/sing-box.service
systemctl enable sing-box # 开机启动
chmod +x /root/sing-box/systemctl.sh && bash /root/sing-box/systemctl.sh

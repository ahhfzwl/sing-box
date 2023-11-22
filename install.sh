#!/usr/bin/bash

case "$(uname -m)" in x86_64|amd64|x64)CPU=amd64;;i386|i686)CPU=386;;armv8|arm64|aarch64)CPU=arm64;;armv6l|armv7|armv7l)CPU=armv7;;*)echo "none CPU" && exit;esac && echo $CPU
VERSION=$(curl https://api.github.com/repos/SagerNet/sing-box/releases | grep -oP "sing-box-\d+\.\d+\.\d+-linux-$CPU"| sort -Vru | head -n 1) && echo "$VERSION"
curl -o /tmp/$VERSION.tar.gz https://github.sock.cf/SagerNet/sing-box/releases/latest/download/$VERSION.tar.gz

apt update && apt install -y openssh-server systemctl wget curl vim nano screen unzip htop
mkdir /root/sing-box/ && cd /root/sing-box/

tar -xvf sing-box-*.tar.gz
cp ./sing-box-*/sing-box /root/sing-box/
rm -rf /root/sing-box/sing-box-*
chmod +x /root/sing-box/sing-box
wget -O /root/sing-box/config.json https://raw.sock.cf/ahhfzwl/sing-box/dev-next/config.json
wget -O /root/sing-box/systemctl.sh https://raw.sock.cf/ahhfzwl/sing-box/dev-next/systemctl.sh
wget -O /etc/systemd/system/sing-box.service https://raw.sock.cf/ahhfzwl/sing-box/dev-next/sing-box.service
systemctl enable sing-box # 开机启动

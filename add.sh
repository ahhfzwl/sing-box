#!/bin/bash -e

case `uname -m` in x86_64|amd64|x64)CPU=amd64;;i386|i686)CPU=386;;armv8|arm64|aarch64)CPU=arm64;;armv6l|armv7|armv7l)CPU=armv7;;*)echo CPU???;exit;esac
VER=$(curl https://api.github.com/repos/SagerNet/sing-box/releases | grep -oP "sing-box-\d+\.\d+\.\d+-linux-$CPU"| sort -Vru | head -n 1)
curl -Lo /tmp/$VER.tar.gz https://github.sock.cf/SagerNet/sing-box/releases/latest/download/$VER.tar.gz
tar -xzf /tmp/$VER.tar.gz -C /tmp/
cp /tmp/sing-box-*/sing-box /usr/local/bin/sing-box
chmod +x /usr/local/bin/sing-box
rm -rf /tmp/sing-box-*
mkdir /etc/sing-box
curl -Lo /etc/sing-box/config.json https://raw.githubusercontent.com/ahhfzwl/sing-box/main/config.json
sing-box run -c /etc/sing-box/config.json >/dev/null 2>&1 &

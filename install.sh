#!/bin/bash
SING=$1
apk() {
  APK=
  for i in systemctl htop nano wget curl
  do
    if [ -z `type -P $i` ]; then
      APK="$APK $i"
    fi
  done
  if [ -z $APK ]; then
    echo "APK OK"
  else
    apt update && apt -y install $APK
  fi
}

add() {
  case `uname -m` in x86_64|amd64|x64)CPU=amd64;;i386|i686)CPU=386;;armv8|arm64|aarch64)CPU=arm64;;armv6l|armv7|armv7l)CPU=armv7;;*)echo CPU???;exit;esac
  VER=$(curl https://api.github.com/repos/SagerNet/sing-box/releases | grep -oP "sing-box-\d+\.\d+\.\d+-linux-$CPU"| sort -Vru | head -n 1)
  curl -Lo /tmp/$VER.tar.gz https://github.sock.cf/SagerNet/sing-box/releases/latest/download/$VER.tar.gz
  tar -xzf /tmp/$VER.tar.gz -C /tmp/
  cp /tmp/sing-box-*/sing-box /usr/local/bin/sing-box
  chmod +x /usr/local/bin/sing-box
  rm -rf /tmp/sing-box-*
  mkdir /etc/sing-box
  curl -Lo /etc/sing-box/config.json https://raw.githubusercontent.com/ahhfzwl/sing-box/main/config.json
  curl -Lo /etc/sing-box/sock.cf.car https://raw.githubusercontent.com/ahhfzwl/sing-box/main/sock.cf.cer
  curl -Lo /etc/sing-box/sock.cf.key https://raw.githubusercontent.com/ahhfzwl/sing-box/main/sock.cf.key
  curl -Lo /etc/systemd/system/sing-box.service https://raw.githubusercontent.com/ahhfzwl/sing-box/main/sing-box.service
  curl -Lo /etc/init.d/sing-box https://raw.githubusercontent.com/ahhfzwl/sing-box/main/sing-box
  systemctl restart sing-box
  systemctl enable sing-box
}

del() {
  systemctl disable sing-box
  systemctl stop sing-box
  rm -rf /etc/systemd/system/sing-box.service
  rm -rf /etc/sing-box
  rm -rf /usr/local/bin/sing-box
  rm -rf /etc/init.d/sing-box
}

case $SING in
  add) apk && add;;
  del) del;;
  *) echo "add or del" && exit;
esac

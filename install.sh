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
  mkdir /etc/sing-box
  echo "download /etc/sing-box/config.json"
  curl -Lso /etc/sing-box/config.json https://raw.sock.cf/ahhfzwl/sing-box/main/config.json
  echo "download /etc/sing-box/sock.cf.car"
  curl -Lso /etc/sing-box/sock.cf.car https://raw.sock.cf/ahhfzwl/sing-box/main/sock.cf.cer
  echo "download /etc/sing-box/sock.cf.key"
  curl -Lso /etc/sing-box/sock.cf.key https://raw.sock.cf/ahhfzwl/sing-box/main/sock.cf.key
  echo "download /etc/systemd/system/sing-box.service"
  curl -Lso /etc/systemd/system/sing-box.service https://raw.sock.cf/ahhfzwl/sing-box/main/sing-box.service
  echo "download /etc/init.d/sing-box"
  curl -Lso /etc/init.d/sing-box https://raw.sock.cf/ahhfzwl/sing-box/main/sing-box
  chmod +x /etc/init.d/sing-box
  case `uname -m` in x86_64|amd64|x64)CPU=amd64;;i386|i686)CPU=386;;armv8|arm64|aarch64)CPU=arm64;;armv6l|armv7|armv7l)CPU=armv7;;*)echo CPU???;exit;esac
  VER=$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases | grep -oP "sing-box-\d+\.\d+\.\d+-linux-$CPU"| sort -Vru | head -n 1)
  echo "download $VER.tar.gz"
  curl -Lo /tmp/$VER.tar.gz https://github.sock.cf/SagerNet/sing-box/releases/latest/download/$VER.tar.gz
  tar -xzf /tmp/$VER.tar.gz -C /tmp/
  cp /tmp/sing-box-*/sing-box /usr/local/bin/sing-box
  chmod +x /usr/local/bin/sing-box
  rm -rf /tmp/sing-box-*
  systemctl daemon-reload
  systemctl restart sing-box
  systemctl enable sing-box
}

del() {
  echo "disable sing-box"
  systemctl disable sing-box
  echo "stop sing-box"
  systemctl stop sing-box
  echo "del /etc/systemd/system/sing-box.service"
  rm -rf /etc/systemd/system/sing-box.service
  echo "del /etc/sing-box"
  rm -rf /etc/sing-box
  echo "del /usr/local/bin/sing-box"
  rm -rf /usr/local/bin/sing-box
  echo "del /etc/init.d/sing-box"
  rm -rf /etc/init.d/sing-box
}

case $SING in
  add)
    apk
    add
  ;;
  del)
    del
  ;;
  *)
    echo "add or del"
    exit
  ;;
esac

#!/bin/bash
SING=$1

install_packages() {
  local packages=("cron" "htop" "nano" "wget" "curl")
  local to_install=()
  for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q "^ii  $pkg "; then
      to_install+=("$pkg")
    fi
  done

  if [ "${#to_install[@]}" -eq 0 ]; then
    echo "所有软件包均已安装。"
  else
    local package_list="${to_install[*]}"
    echo "安装软件包: $package_list"
    apt update && apt -y install $package_list
  fi
}

install_sing-box() {
  mkdir /etc/sing-box
  echo "download /etc/sing-box/config.json"
  wget -O /etc/sing-box/config.json https://raw.sock.cf/ahhfzwl/sing-box/main/$CONFIG
  echo "download /etc/sing-box/sock.cf.car"
  wget -O /etc/sing-box/sock.cf.cer https://raw.sock.cf/ahhfzwl/sing-box/main/sock.cf.cer
  echo "download /etc/sing-box/sock.cf.key"
  wget -O /etc/sing-box/sock.cf.key https://raw.sock.cf/ahhfzwl/sing-box/main/sock.cf.key
  echo "download /etc/systemd/system/sing-box.service"
  wget -O /etc/systemd/system/sing-box.service https://raw.sock.cf/ahhfzwl/sing-box/main/sing-box.service
  echo "download /etc/init.d/sing-box"
  wget -O /etc/init.d/sing-box https://raw.sock.cf/ahhfzwl/sing-box/main/sing-box
  chmod +x /etc/init.d/sing-box
  wget "$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest | grep -o "https://github.com/SagerNet/sing-box/releases/download/.*/sing-box-.*-linux-$(uname -m | sed 's/x86_/amd/; s/aarch/arm/').tar.gz" | sort -V | head -n 1)"
  tar -zxvf sing-box-*
  mv ./sing-box-*/sing-box /usr/local/bin/
  rm -rf sing-box-*
  systemctl daemon-reload
  systemctl restart sing-box
  systemctl enable sing-box
}

remove_sing-box() {
  echo "disable sing-box"
  systemctl disable sing-box
  echo "stop sing-box"
  systemctl stop sing-box
  pkill sing-box
  echo "del /etc/systemd/system/sing-box.service"
  rm -rf /etc/systemd/system/sing-box.service
  echo "del /etc/sing-box"
  rm -rf /etc/sing-box
  echo "del /usr/local/bin/sing-box"
  rm -rf /usr/local/bin/sing-box
  echo "del /etc/init.d/sing-box"
  rm -rf /etc/init.d/sing-box
  systemctl daemon-reload
}

case $SING in
  add)
    CONFIG=config.json
    install_packages
    install_sing-box
  ;;
  del)
    remove_sing-box
  ;;
  warp)
    CONFIG=config-warp.json
    install_packages
    install_sing-box
  ;;
  *)
    echo "add or del"
    exit
  ;;
esac

#!/bin/bash -e
SING=$1
apk() {
  APK=
  for i in systemctl cron curl nano
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
  case "$(uname -m)" in x86_64|amd64|x64)CPU=amd64;;i386|i686)CPU=386;;armv8|arm64|aarch64)CPU=arm64;;armv6l|armv7|armv7l)CPU=armv7;;*)echo "none CPU" && exit;esac
  VERSION=$(curl https://api.github.com/repos/SagerNet/sing-box/releases | grep -oP "sing-box-\d+\.\d+\.\d+-linux-$CPU"| sort -Vru | head -n 1)
  curl -Lo /tmp/$VERSION.tar.gz https://github.sock.cf/SagerNet/sing-box/releases/latest/download/$VERSION.tar.gz
  tar -xzf /tmp/$VERSION.tar.gz -C /tmp/
  cp /tmp/sing-box-*/sing-box /usr/local/bin/sing-box
  chmod +x /usr/local/bin/sing-box
  rm -rf /tmp/sing-box-*
  
  mkdir /etc/sing-box
  cat <<'TEXT' > /etc/sing-box/config.json
  {
    "inbounds":[
      {
        "type": "vmess",
        "listen": "::",
        "listen_port": 8080,
        "users": [
          {
            "name": "vmess",
            "uuid": "11112222-3333-4444-aaaa-bbbbccccdddd"
          }
        ],
        "transport": {
          "type": "ws",
          "path": "/vm",
          "early_data_header_name": "Sec-WebSocket-Protocol"
        }
      }
    ],
    "outbounds":[{"type":"direct"}]
  }
TEXT
  
  cat <<'TEXT' > /etc/systemd/system/sing-box.service
  [Unit]
  Description=sing-box
  After=network.target
  
  [Install]
  WantedBy=multi-user.target
  
  [Service]
  Type=simple
  WorkingDirectory=/usr/local/bin/
  ExecStart=/usr/local/bin/sing-box run -c /etc/sing-box/config.json
  Restart=always
TEXT
  
  systemctl enable sing-box
  systemctl restart sing-box
}

del() {
  systemctl stop sing-box
  systemctl disable sing-box
  rm -rf /etc/systemd/system/sing-box.service
  rm -rf /etc/sing-box
  rm -rf /usr/local/bin/sing-box
}

if [[ $SING == add ]]; then
  apk
  add
elif [[ $SING == del ]]; then
  del
else
  echo "add del"
fi
$SING

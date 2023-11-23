#!/bin/bash -e
name=$1
zone_id=c7f5c9cdf1f4856c61075acc4446399c
api_tokens=iil1s-cmyM9veyYLVBa9E9_zivTrUqTkcSuKUl1N
file=/tmp/$name
[ -e $file ] && old=`cat $file`

function apk(){
  APK=
  for i in wget curl cron nano screen
  do
    if [ -z `type -P $i` ]; then
      APK="$APK $i"
    fi
  done
  if [ -z $APK ]; then
    echo true
  else
    apt update && apt -y install $APK
  fi
}
function add(){
  case "$(uname -m)" in x86_64|amd64|x64)CPU=amd64;;i386|i686)CPU=386;;armv8|arm64|aarch64)CPU=arm64;;armv6l|armv7|armv7l)CPU=armv7;;*)echo "none CPU" && exit;esac
  VERSION=$(curl https://api.github.com/repos/SagerNet/sing-box/releases | grep -oP "sing-box-\d+\.\d+\.\d+-linux-$CPU"| sort -Vru | head -n 1)
  curl -Lo /tmp/$VERSION.tar.gz https://github.sock.cf/SagerNet/sing-box/releases/latest/download/$VERSION.tar.gz
  tar -xzf /tmp/$VERSION.tar.gz -C /tmp/
  cp /tmp/sing-box-*/sing-box /usr/local/bin/
  chmod +x /usr/local/bin/sing-box
  rm -rf /tmp/sing-box-*
  
  mkdir /etc/sing-box/
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

if [ -z "$name" ]; then
	echo "No new IP found"
elif [ "$old" = "$new" ]; then
	echo "$(date) $new IP address unchanged"
else
	cloudflaredns $new
fi

#!/bin/bash

curl -LO https://github.sock.cf/SagerNet/sing-box/releases/download/v1.6.5/sing-box-1.6.5-linux-amd64.tar.gz
tar -xvf ./sing-box-*.tar.gz
cp ./sing-box-*/sing-box /usr/bin/sing-box
chmod +x /usr/bin/sing-box
rm -rf ./sing-box-*

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
WorkingDirectory=/usr/bin/
ExecStart=/usr/bin/sing-box run -c /etc/sing-box/config.json
Restart=always
TEXT

systemctl enable sing-box
systemctl restart sing-box

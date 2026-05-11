cat > /etc/systemd/system/sing-box.service << "EOF"
[Unit]
Description=sing-box
After=network.target

[Service]
ExecStart=/usr/local/bin/sing-box run -c /etc/sing-box/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload && systemctl enable sing-box && systemctl start sing-box

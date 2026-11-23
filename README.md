### apt install -y ing-box
```bash
ARCH=$(case "$(uname -m)" in x86_64|amd64) echo amd64;; aarch64|arm64) echo arm64;; *) uname -m;; esac)
VER=$(curl -sI https://833337.xyz/SagerNet/sing-box/releases/latest | grep -i "^location:" | awk -F'/' '{print $NF}' | tr -d '\r' | sed 's/^v//')
curl -LO "https://833337.xyz/SagerNet/sing-box/releases/download/v${VER}/sing-box-${VER}-linux-${ARCH}.tar.gz"
tar -xzOf "sing-box-${VER}-linux-${ARCH}.tar.gz" "sing-box-${VER}-linux-${ARCH}/sing-box" > /usr/local/bin/sing-box
rm -f "sing-box-${VER}-linux-${ARCH}.tar.gz"
sing-box version
```
### systemctl status sing-box
```
cat <<\EOF >/etc/systemd/system/sing-box.service
[Unit]
Description=sing-box
After=network.target

[Service]
WorkingDirectory=/etc/sing-box/
ExecStart=/usr/local/bin/sing-box run
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload && systemctl enable sing-box && systemctl start sing-box
```
### /etc/init.d/sing-box status
```
cat <<'EOF' > /etc/init.d/sing-box
#!/bin/bash
DAEMON="/usr/local/bin/sing-box"
CONFIG="/etc/sing-box/config.json"
LOG="/var/log/sing-box.log"
PID="/run/sing-box.pid"

start() {
  mkdir -p "$(dirname "$LOG")"
  setsid "$DAEMON" run -c "$CONFIG" >> "$LOG" 2>&1 < /dev/null &
  echo $! > "$PID"
}

stop() {
  [ -f "$PID" ] && kill "$(cat "$PID")" 2>/dev/null
  rm -f "$PID"
}

case "$1" in
  start) start ;;
  stop) stop ;;
  restart) stop; sleep 1; start ;;
  status|*) [ -f "$LOG" ] && tail -n 50 -f "$LOG" || echo "暂无日志文件：$LOG" ;;
esac
EOF

chmod +x /etc/init.d/sing-box
```
### supervisorctl -c /etc/supervisor/conf.d/supervisord.conf status sing-box
```
cat <<'EOF' > /etc/supervisor/conf.d/sing-box.conf
[program:sing-box]
command=/usr/local/bin/sing-box run -c /etc/sing-box/config.json
stderr_logfile=/var/log/supervisor/sing-box.err.log
stdout_logfile=/var/log/supervisor/sing-box.out.log
EOF
```

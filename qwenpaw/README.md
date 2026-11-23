### apt install -y ing-box
```bash
ARCH=$(case "$(uname -m)" in x86_64|amd64) echo amd64;; aarch64|arm64) echo arm64;; *) uname -m;; esac)
VER=$(curl -sI https://833337.xyz/SagerNet/sing-box/releases/latest | grep -i "^location:" | awk -F'/' '{print $NF}' | tr -d '\r' | sed 's/^v//')
curl -LO "https://833337.xyz/SagerNet/sing-box/releases/download/v${VER}/sing-box-${VER}-linux-${ARCH}.tar.gz"
tar -xzOf "sing-box-${VER}-linux-${ARCH}.tar.gz" "sing-box-${VER}-linux-${ARCH}/sing-box" > /usr/local/bin/sing-box
rm -f "sing-box-${VER}-linux-${ARCH}.tar.gz"
sing-box version
```
### /etc/sing-box/config.json
```
mkdir -p /etc/sing-box && cat << 'EOF' > /etc/sing-box/config.json
{
  "inbounds": [
    {
      "type": "cloudflared",
      "token": "eyJhIjoiODZkOTQwNGQ1OTZkNTk0MTFkY2UxNzcwYWIxOW",
      "ha_connections": 0,
      "protocol": "quic",
      "edge_ip_version": 4
    },
    {
      "type": "vless",
      "listen_port": 8880,
      "users": [{"uuid": "11112222-3333-4444-aaaa-bbbbccccdddd"}],
      "transport": {"type": "ws","path": "/vl"}
    }
  ],
  "outbounds": [{"type": "direct"}]
}
EOF
```
### supervisorctl -c /etc/supervisor/conf.d/supervisord.conf status sing-box
```
cat <<'EOF' >> /etc/supervisor/conf.d/supervisord.conf
[program:sing-box]
command=/usr/local/bin/sing-box run -c /etc/sing-box/config.json
stderr_logfile=/var/log/supervisor/sing-box.err.log
stdout_logfile=/var/log/supervisor/sing-box.out.log
EOF
supervisorctl reread && supervisorctl update && supervisorctl status sing-box
```

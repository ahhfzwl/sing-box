apt install -y ing-box
```bash
ARCH=$(case "$(uname -m)" in x86_64|amd64) echo amd64;; aarch64|arm64) echo arm64;; *) uname -m;; esac)
VER=$(curl -sI https://833337.xyz/SagerNet/sing-box/releases/latest | grep -i "^location:" | awk -F'/' '{print $NF}' | tr -d '\r' | sed 's/^v//')
curl -LO "https://833337.xyz/SagerNet/sing-box/releases/download/v${VER}/sing-box-${VER}-linux-${ARCH}.tar.gz"
tar -xzOf "sing-box-${VER}-linux-${ARCH}.tar.gz" "sing-box-${VER}-linux-${ARCH}/sing-box" > /usr/local/bin/sing-box
rm -f "sing-box-${VER}-linux-${ARCH}.tar.gz"
sing-box version
```
systemctl status sing-box
```bash
curl -fsSL https://833337.xyz/_gh/raw/ahhfzwl/sing-box/main/etc/systemd/system/sing-box.service -o /etc/systemd/system/sing-box.service
systemctl daemon-reload && systemctl enable sing-box && systemctl start sing-box
```
/etc/init.d/sing-box status
```

```
supervisorctl -c /etc/supervisor/conf.d/supervisord.conf status sing-box
```

```

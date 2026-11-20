```
ARCH="amd64"
VER=$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest | sed -nE 's/.*"tag_name":[[:space:]]*"v([^"]+)".*/\1/p' | head -n1)
curl -f "https://833337.xyz/SagerNet/sing-box/releases/download/v${VER}/sing-box-${VER}-linux-${ARCH}.tar.gz" | tar -xz --strip-components=1 -C /usr/local/bin/ "sing-box-${VER}-linux-${ARCH}/sing-box"
```

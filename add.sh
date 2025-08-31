#!/bin/sh
set -e

UUID="11112222-3333-4444-aaaa-bbbbccccdddd"

menu() {
  echo "=========================="
  echo " Sing-box 管理脚本"
  echo "=========================="
  echo "1) 安装/更新 Sing-box"
  echo "2) 卸载 Sing-box"
  echo "=========================="
  read -p "请选择 [1-2]: " OPT
}

detect_pkg_mgr() {
  if command -v apk >/dev/null 2>&1; then
    PKG="apk add --no-cache"
  elif command -v apt-get >/dev/null 2>&1; then
    PKG="apt-get update && apt-get install -y"
  elif command -v yum >/dev/null 2>&1; then
    PKG="yum install -y"
  else
    echo "❌ 未检测到可用的包管理器"
    exit 1
  fi
}

detect_arch() {
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64)   ARCH_TAG="amd64" ;;
    aarch64)  ARCH_TAG="arm64" ;;
    armv7l)   ARCH_TAG="armv7" ;;
    i386|i686) ARCH_TAG="386" ;;
    *) echo "❌ 不支持的架构: $ARCH"; exit 1 ;;
  esac
}

install_singbox() {
  # 选择协议
  echo "请选择协议类型："
  echo "1) vless"
  echo "2) vmess"
  read -p "输入数字 (默认 1): " PROTO_OPT
  case "$PROTO_OPT" in
    2) PROTO="vmess" ;;
    *) PROTO="vless" ;;
  esac

  # 输入端口
  read -p "请输入服务端监听端口 [默认: 443]：" PORT
  PORT=${PORT:-443}

  # 是否启用 TLS
  echo "是否启用 TLS？"
  echo "1) 启用 (自签证书)"
  echo "2) 不启用"
  read -p "输入数字 (默认 2): " TLS_OPT
  case "$TLS_OPT" in
    1) USE_TLS=1 ;;
    *) USE_TLS=0 ;;
  esac

  # 安装依赖
  detect_pkg_mgr
  $PKG curl unzip openssl >/dev/null 2>&1 || true

  # 获取最新版号
  VER=$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest | grep tag_name | cut -d '"' -f4)

  # 检测架构
  detect_arch

  # 下载并安装 sing-box
  cd /tmp
  curl -L -o sing-box.tar.gz https://github.com/SagerNet/sing-box/releases/download/$VER/sing-box-$VER-linux-$ARCH_TAG.tar.gz
  tar -xzf sing-box.tar.gz
  mv sing-box-*/sing-box /usr/local/bin/
  chmod +x /usr/local/bin/sing-box

  # 配置目录
  mkdir -p /etc/sing-box

  # TLS 证书
  TLS_JSON=""
  if [ "$USE_TLS" -eq 1 ]; then
    mkdir -p /etc/sing-box/certs
    openssl req -new -x509 -days 3650 -nodes -subj "/CN=sing-box.local" \
      -out /etc/sing-box/certs/cert.pem -keyout /etc/sing-box/certs/key.pem
    TLS_JSON=$(cat <<EOF
,
      "tls": {
        "enabled": true,
        "certificate_path": "/etc/sing-box/certs/cert.pem",
        "key_path": "/etc/sing-box/certs/key.pem"
      }
EOF
)
  fi

  # 写配置文件
  cat >/etc/sing-box/config.json <<EOF
{
  "log": {
    "level": "info"
  },
  "inbounds": [
    {
      "type": "$PROTO",
      "listen": "::",
      "listen_port": $PORT,
      "users": [
        {
          "uuid": "$UUID"
        }
      ],
      "transport": {
        "type": "ws",
        "path": "/"
      }$TLS_JSON
    }
  ],
  "outbounds": [
    {
      "type": "direct"
    },
    {
      "type": "block"
    }
  ]
}
EOF

  # 判断 init 系统 (systemd / openrc)
  if command -v systemctl >/dev/null 2>&1; then
    # systemd
    cat >/etc/systemd/system/sing-box.service <<EOF
[Unit]
Description=Sing-box Service
After=network.target

[Service]
ExecStart=/usr/local/bin/sing-box -c /etc/sing-box/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable sing-box
    systemctl restart sing-box
  else
    # openrc
    cat >/etc/init.d/sing-box <<'EOF'
#!/sbin/openrc-run
command="/usr/local/bin/sing-box"
command_args="-c /etc/sing-box/config.json"
pidfile="/run/sing-box.pid"
command_background="yes"

depend() {
    need net
}
EOF
    chmod +x /etc/init.d/sing-box
    rc-update add sing-box default
    rc-service sing-box restart
  fi

  # 输出信息
  echo "✅ sing-box $VER 已安装并设置开机自启"
  echo "协议：$PROTO + WS"
  if [ "$USE_TLS" -eq 1 ]; then
    echo "TLS：启用 (自签证书 /etc/sing-box/certs/)"
  else
    echo "TLS：未启用"
  fi
  echo "端口：$PORT"
  echo "UUID：$UUID"
}

uninstall_singbox() {
  echo "⏳ 正在卸载 sing-box ..."
  if command -v systemctl >/dev/null 2>&1; then
    systemctl stop sing-box || true
    systemctl disable sing-box || true
    rm -f /etc/systemd/system/sing-box.service
    systemctl daemon-reload
  else
    rc-service sing-box stop || true
    rc-update del sing-box || true
    rm -f /etc/init.d/sing-box
  fi
  rm -f /usr/local/bin/sing-box
  rm -rf /etc/sing-box
  echo "✅ sing-box 已卸载完成"
}

# 主菜单
menu
if [ "$OPT" = "1" ]; then
  install_singbox
elif [ "$OPT" = "2" ]; then
  uninstall_singbox
else
  echo "❌ 输入错误，退出。"
  exit 1
fi

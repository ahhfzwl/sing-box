apt update && apt install -y wget curl vim

mkdir /root/sing-box-warp/ && cd /root/sing-box-warp/

wget -O /root/sing-box-warp/sing-box https://github.sock.cf/ahhfzwl/sing-box/releases/download/1/sing-box

wget -O /root/sing-box-warp/config.json https://github.sock.cf/ahhfzwl/sing-box/blob/dev-next/config.json

wget -O /etc/systemd/system/sing-box-warp.service https://github.sock.cf/ahhfzwl/sing-box/blob/dev-next/sing-box.service

chmod +x /root/sing-box-warp/sing-box

systemctl restart sing-box-warp # 重启服务

systemctl enable sing-box-warp # 开机启动

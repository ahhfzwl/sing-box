# 卸载(ubuntu)：

bash <(curl -Ls https://raw.sock.cf/ahhfzwl/sing-box/main/sing-box.sh) del


# 安装(ubuntu)：

bash <(curl -Ls https://raw.sock.cf/ahhfzwl/sing-box/main/sing-box.sh) add


# WARP账户：

https://fscarmen.cloudflare.now.cc/


# 手动安装sing-box：

wget https://github.com/SagerNet/sing-box/releases/download/v1.8.2/sing-box-1.8.2-linux-arm64.tar.gz

tar -zxvf sing-box-*

mv ./sing-box-*/sing-box /usr/local/bin/

rm -rf sing-box-*

mkdir /etc/sing-box && wget -O /etc/sing-box/config.json https://raw.sock.cf/ahhfzwl/sing-box/main/config.json

sed -i '6s/8080/8080/' /etc/sing-box/config.json

setsid sing-box run -c /etc/sing-box/config.json > /dev/null 2>&1 &

安装：

bash <(curl -Ls https://raw.sock.cf/ahhfzwl/sing-box/main/install.sh) add


改端口：

sed -i '6s/8080/30501/' /etc/sing-box/config.json && systemctl restart sing-box


卸载：

bash <(curl -Ls https://raw.sock.cf/ahhfzwl/sing-box/main/install.sh) del


WARP账户：

https://fscarmen.cloudflare.now.cc/


下载sing-box最新版：

mkdir /etc/sing-box && curl -o /etc/sing-box/config.json https://raw.sock.cf/ahhfzwl/sing-box/main/config.json

wget https://github.com/SagerNet/sing-box/releases/latest/download/$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases | grep -oP "sing-box-\d+\.\d+\.\d+-linux-$(dpkg --print-architecture)"| sort -Vru | head -n 1).tar.gz

tar -zxvf sing-box-*

mv ./sing-box-*/sing-box /usr/local/bin/

sing-box run -c /etc/sing-box/config.jaon

安装：

bash <(curl -Ls https://raw.sock.cf/ahhfzwl/sing-box/main/install.sh) add


卸载：

bash <(curl -Ls https://raw.sock.cf/ahhfzwl/sing-box/main/install.sh) del


WARP账户：

https://fscarmen.cloudflare.now.cc/


下载sing-box最新版：

wget https://github.com/SagerNet/sing-box/releases/latest/download/$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases | grep -oP "sing-box-\d+\.\d+\.\d+-linux-$(dpkg --print-architecture)"| sort -Vru | head -n 1).tar.gz

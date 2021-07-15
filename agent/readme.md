# nginx-instance-manager

## upgrade VM

- unzip and upgrade

```bash
scp ./nginx-instance-manager-1.0.0.tar.gz user@my-nginx.domain.com:~/
ssh user@my-nginx.domain.com
mkdir -p ~/nim
tar -xvf nginx-instance-manager-1.0.0.tar.gz -C ~/nim
# update
sudo apt-get update
# nim
sudo apt-get -y upgrade ~/nim/deb/nginx-manager-1.0.0-329302650_amd64.deb
# agent
sudo apt-get -y upgrade ~/nim/deb/nginx-manager-1.0.0-329302650_amd64.deb
# restart and check
sudo systemctl restart nginx-agent
sudo systemctl restart nginx-manager
# if errors look at conf
cat /etc/nginx-agent/nginx-agent.conf
# sudo nano /etc/nginx-agent/nginx-agent.conf
# common errors
# defaulted api target to 127.0.0.1
# mtls enabled
cat /etc/nginx-manager/nginx-manager.conf
# sudo nano /etc/nginx-manager/nginx-manager.conf
# common errors
# defaulted listner to 127.0.0.1
# mtls enabled in tls block
sudo systemctl status nginx-agent
sudo systemctl status nginx-manager
```

## docker debian
```dockerfile
  # install
  RUN set -x \
    && wget https://nginx.org/keys/nginx_signing.key \
    && apt-key add nginx_signing.key \
    # nginx-agent
    && printf "deb https://pkgs.nginx.com/instance-manager/debian stable nginx-plus\n" | tee /etc/apt/sources.list.d/instance-manager.list \
    && wget -q -O /etc/apt/apt.conf.d/90pkgs-nginx https://cs.nginx.com/static/files/90pkgs-nginx \
    && apt-get clean \
    && apt-get update \
    && apt-get install -y nginx-agent \
```

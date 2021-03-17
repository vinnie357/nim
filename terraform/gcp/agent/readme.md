## agent install
```bash


printf "deb https://pkgs.nginx.com/instance-manager/debian stable nginx-plus\n" | tee /etc/apt/sources.list.d/instance-manager.list
wget -q -O /etc/apt/apt.conf.d/90pkgs-nginx https://cs.nginx.com/static/files/90pkgs-nginx
apt-get update
apt-get install -y nginx-agent

# service
systemctl start nginx-agent
systemctl enable nginx-agent
```
## agent conf
```bash
mkdir -p /etc/nginx-agent/
cat << EOF > /etc/nginx-agent/nginx-agent.conf
#
# /etc/nginx-agent/nginx-agent.conf
#

# Configuration file for NGINX Agent
server: 10.0.30.2:10000
log:
  level: info
  path: /var/log/nginx-agent/
tags:
  location: unspecified
nginx:
  bin_path: /usr/sbin/nginx
  basic_status_url: "http://127.0.0.1:80/nginx_status"
  plus_api_url: "http://127.0.0.1:8080/api"
  metrics_poll_interval: 1000ms
EOF
```

## remote install
```bash
sudo su - root
# download agent
sudo apt download nginx-agent
agentrpm=$(ls $PWD/nginx-agent*.deb | tail -n 1)
echo $agentrpm
## install
agentsystem="10.0.30.3" # remove system hostname/FQDN
agentuser="vinnie" # username with sudo privileges
scp $agentrpm $agentuser@$agentsystem:./
scp /etc/nginx-agent/nginx-agent.conf $agentuser@$agentsystem:./
ssh $agentuser@$agentsystem sudo apt install -y ./nginx-agent*.deb
ssh $agentuser@$agentsystem sudo cp nginx-agent.conf /etc/nginx-agent/nginx-agent.conf
ssh $agentuser@$agentsystem sudo systemctl enable nginx-agent --now # For systemd-based systems
ssh $agentuser@$agentsystem systemctl status nginx-agent # Confirm it ran successfully

cat << EOF > server_list.txt
10.0.30.3
10.0.30.4
EOF

### serverlist
serverlist=server_list.txt # use a file for a list of the systems
cat $serverlist
#!/bin/bash
for ip in `cat $serverlist`; do
  ssh-copy-id -i ~/.ssh/id_rsa.pub $ip
done
```

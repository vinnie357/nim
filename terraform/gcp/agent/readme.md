# agent install
  ${myinstance}/docs/tutorials/manage-instance/

  https://docs.nginx.com/nginx-instance-manager/getting-started/agent/

## local install
```bash
sudo su - root
## vars
secretName="mysecret"
server="10.0.30.8"
## prep
echo "==== secrets ===="
# access secret from secretsmanager
secrets=$(gcloud secrets versions access latest --secret="${secretName}")
## install cert key
echo "setting info from Metadata secret"
## cert
cat << EOF > /etc/ssl/nginx/nginx-repo.crt
$(echo $secrets | jq -r .cert)
EOF
## key
cat << EOF > /etc/ssl/nginx/nginx-repo.key
$(echo $secrets | jq -r .key)
EOF
echo "==== packages ===="
apt-get update
apt-get install jq apt-transport-https lsb-release ca-certificates -y
echo "==== signing key ===="
wget https://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key
## repos
echo "==== repos ===="
printf "deb https://pkgs.nginx.com/instance-manager/debian stable nginx-plus\n" | tee /etc/apt/sources.list.d/instance-manager.list
wget -q -O /etc/apt/apt.conf.d/90pkgs-nginx https://cs.nginx.com/static/files/90pkgs-nginx
apt-get clean
apt-get update
## download optional
# apt-get download nginx-agent
## config
echo "==== config ===="
cat << EOF > nginx-agent.conf
#
# /etc/nginx-agent/nginx-agent.conf
#

# Configuration file for NGINX Agent
server: ${server}:10000
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
## install
echo "==== install ===="
apt-get install -y nginx-agent
# sudo apt-get install -y ./nginx-agent*.deb
echo "==== service ===="
## service
sudo systemctl enable nginx-agent --now
cat /var/log/nginx-agent/nginx-agent.log
echo "==== done ===="

```

## remote install
```bash
## install
### vars
server="104.196.169.81"
server_private="192.168.3.63"
## gcp
server_private=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip' -H 'Metadata-Flavor: Google')
cidr="10.0.30.0/24"
### agent conf
cat << EOF > /etc/nginx-agent/nginx-agent.conf
#
# /etc/nginx-agent/nginx-agent.conf
#

# Configuration file for NGINX Agent
server: ${server_private}:10000
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
### serverlist
# scan cidr
curl -ks -X POST "https://${server}/api/v0/scan" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{  \"cidr\": \"${cidr}\",  \"ports\": [    80, 443  ]}"
# collect results
cat << EOF > server_list.txt
$(curl -ks -X GET "https://${server}/api/v0/scan/servers" -H  "accept: application/json" | jq -r .list[].ip)
EOF
#!/bin/bash
## get package
sudo apt-get download nginx-agent
serverlist=./server_list.txt
cat $serverlist
agentuser=$USER #replace with the username you are using for ssh
package=deb #replace with deb for debian/ubuntu
#agentpackage=$(ls $PWD/nginx-agent*.rpm | tail -n 1) # for rpm package if not defined
agentpackage=$(ls $PWD/nginx-agent*.deb | tail -n 1) # for deb package if not defined
agentconf=/etc/nginx-agent/nginx-agent.conf

if [ "${package}" == 'rpm' ]; then
  packagerinstall="yum install -y"
elif [ "${package}" == 'deb' ]; then
  packagerinstall="apt install"
fi

for agenthostname in `cat $serverlist`; do
  scp $agentpackage $agentuser@$agenthostname:./
  ssh $agentuser@$agenthostname sudo "$packagerinstall ./nginx-agent*.$package"
  scp $agentconf $agentuser@$agenthostname:./
  ssh $agentuser@$agenthostname sudo systemctl enable nginx-agent --now
  echo "Installed nginx-agent on $agenthostname..."
done

```

## install one
```bash
## expects ssh key in user profile and public on remote.
local_ipv4="$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")"
## agent conf
cat << EOF > nginx-agent.conf
#
# /etc/nginx-agent/nginx-agent.conf
#

# Configuration file for NGINX Agent
server: $local_ipv4:10000
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
## install
agentuser=vinnie
agenthostname=10.0.30.4
agentconf=./nginx-agent.conf
sudo apt-get download nginx-agent
agentpackage=$(ls $PWD/nginx-agent*.deb | tail -n 1)
scp $agentpackage $agentuser@$agenthostname:~/
ssh $agentuser@$agenthostname sudo "sudo apt-get install -y  ./nginx-agent*.deb"
scp $agentconf $agentuser@$agenthostname:~/nginx-agent.conf
ssh $agentuser@$agenthostname sudo mv -f ~/nginx-agent.conf /etc/nginx-agent/nginx-agent.conf
ssh $agentuser@$agenthostname sudo systemctl enable nginx-agent --now
```

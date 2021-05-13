# NIM startup
# logging
LOG_FILE="/var/log/startup.log"
if [ ! -e $LOG_FILE ]
then
     touch $LOG_FILE
     exec &>>$LOG_FILE
else
    #if file exists, exit as only want to run once
    exit
fi
exec 1>$LOG_FILE 2>&1

echo "==== starting ===="
## variables
user="${user}"
apt-get update
apt-get install -y lsb-release apt-transport-https wget unzip jq git software-properties-common python3-pip ca-certificates gnupg-agent

## docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker $user
chown -R $user: /var/run/docker.sock

## nginx
# make folders
mkdir /etc/ssl/nginx
cd /etc/ssl/nginx

# license
echo "==== secrets ===="
# access secret from secretsmanager
secrets=$(gcloud secrets versions access latest --secret="${secretName}")

# install cert key
echo "setting info from Metadata secret"
# cert
cat << EOF > /etc/ssl/nginx/nginx-repo.crt
$(echo $secrets | jq -r .nginxCert)
EOF
# key
cat << EOF > /etc/ssl/nginx/nginx-repo.key
$(echo $secrets | jq -r .nginxKey)
EOF

echo "==== repos ===="
# add repo with signing key
wget https://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key

# nginx-plus
printf "deb https://plus-pkgs.nginx.com/ubuntu `lsb_release -cs` nginx-plus\n" | tee /etc/apt/sources.list.d/nginx-plus.list
wget -q -O /etc/apt/apt.conf.d/90nginx https://cs.nginx.com/static/files/90nginx

apt-get clean
apt-get update

# install
echo "==== install ===="
apt-get install -y nginx-plus

# get localip
echo "=== get ip ==="
local_ipv4="$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")"
# config
echo "==== config ===="


echo "==== certs ===="
path="/etc/ssl/nginx/certs/"
mkdir -p $path
# self signed
echo "====self signed cert===="
openssl genrsa -aes256 -passout pass:1234 -out $${path}/server.pass.key 2048
openssl rsa -passin pass:1234 -in $${path}/server.pass.key -out $${path}/nginx.key
openssl req -new -key $${path}/nginx.key -out $${path}/server.csr -subj "/C=US/ST=testville/L=testerton/O=Test testing/OU=Test Department/CN=$hostname"
openssl x509 -req -sha256 -days 365 -in $${path}/server.csr -signkey $${path}/nginx.key -out $${path}/nginx.crt
rm $${path}/server.pass.key
rm $${path}/server.csr
# from secrets
# # cert
# cat << EOF > /etc/ssl/nginx/nginx.crt
# $(echo $secrets | jq -r .webCert)
# EOF
# # key
# cat << EOF > /etc/ssl/nginx/nginx.key
# $(echo $secrets | jq -r .webKey)
# EOF

# function PLUS_CONFIG {

# echo "==== nginx-plus config done ===="
# }
# PLUS_CONFIG


# NIM agent
function nim_agent () {
if [[ ${agent} != "none" ]]; then
echo "==== install nim agent ===="
printf "deb https://pkgs.nginx.com/instance-manager/debian stable nginx-plus\n" | tee /etc/apt/sources.list.d/instance-manager.list
wget -q -O /etc/apt/apt.conf.d/90pkgs-nginx https://cs.nginx.com/static/files/90pkgs-nginx
apt-get clean
apt-get update
apt-get install -y nginx-agent
nim_ipv4="$(gcloud compute instances list --filter "name:nim" --format json | jq .[0] | jq .networkInterfaces | jq -r .[0].networkIP)"
cat << EOF > /etc/nginx-agent/nginx-agent.conf
#
# /etc/nginx-agent/nginx-agent.conf
#

# Configuration file for NGINX Agent
server: $nim_ipv4:10000
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
systemctl start nginx-agent
systemctl enable nginx-agent
else
  echo "====no nim.skipping agent install===="
fi
}
nim_agent
echo "==== start services ===="
systemctl start nginx
systemctl enable nginx
echo "==== done ===="
exit

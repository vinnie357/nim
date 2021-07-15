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

function PLUS_CONFIG {
cat << EOF > /etc/nginx/conf.d/stub-status.conf
#
# /etc/nginx/conf.d/stub-status.conf
#
server {
    listen 127.0.0.1:80;
    server_name 127.0.0.1;
    access_log off; # Don't log access here (test env)
    location /nginx_status {
        stub_status;
    }
}
EOF
cat > /etc/nginx/conf.d/api.conf <<EOF
#
# /etc/nginx/conf.d/api.conf
#
server {
   listen 8080;
   status_zone "Dashboard";
   location /api { api write=on; }
   location /dashboard.html { root /usr/share/nginx/html; }
   access_log off;
   allow  127.0.0.1/32;
   deny   all;
}
EOF
echo "==== nginx-plus config done ===="
}
PLUS_CONFIG

function DOCKER_APPS {
  echo "==== docker apps ===="
  docker run -d --name=grafana -p 3000:3000 grafana/grafana
  docker run -d --name=doom -p 3001:80 nzregularit/js-dos-doom

}
DOCKER_APPS
# NIM agent
function nim_agent () {
if [[ ${agent} != "none" ]]; then
echo "==== install nim agent ===="
printf "deb https://pkgs.nginx.com/instance-manager/debian stable nginx-plus\n" | tee /etc/apt/sources.list.d/instance-manager.list
wget -q -O /etc/apt/apt.conf.d/90pkgs-nginx https://cs.nginx.com/static/files/90pkgs-nginx
apt-get clean
apt-get update
apt-get install -y nginx-agent=${nimVersion}
nim_ipv4="$(gcloud compute instances list --filter "name:nim" --format json | jq .[0] | jq .networkInterfaces | jq -r .[0].networkIP)"
cat << EOF > /etc/nginx-agent/nginx-agent.conf
#
# /etc/nginx-agent/nginx-agent.conf
#

# Configuration file for NGINX Agent

# specify the server grpc port to connect to
server: $nim_ipv4:${nimGrpcPort}

#tls:
  # enable tls in the nginx-manager setup for grpcs
#  enable: true
  # path to certificate
#  cert: /etc/ssl/nginx-manager/agent.crt
  # path to certificate key
#  key: /etc/ssl/nginx-manager/agent.key
  # path to CA cert
#  ca: /etc/ssl/nginx-manager/ca.pem
log:
  # set log level (panic, fatal, error, info, debug, trace; default: info) (default "info")
  level: info
  # set log path. if empty, don't log to file.
  path: /var/log/nginx-agent/
# (optional) tags for this specific instance / machine for inventory purposes
metadata:
  location: unspecified
# instance tags
# tags:
# - web
# - staging
# - etc
# nginx configuration options
nginx:
  # path of nginx to manage
  bin_path: /usr/sbin/nginx
  # specify stub status URL (see: nginx.org/r/stub_status)
  stub_status: "http://127.0.0.1:80/nginx_status"
  # specify plus status api url (see nginx.org/r/api)
  plus_api: "http://127.0.0.1:8080/api"
  # specify metrics poll interval
  metrics_poll_interval: 1000ms
  # specify access logs to exclude from metrics (comma separated)
  #exclude_logs: /var/log/nginx/skipthese*,/var/log/nginx/special-access.log
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

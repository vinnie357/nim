#!/bin/bash
#https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-plus/
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
echo "starting"
apt-get update
apt-get install jq -y
# make folders
mkdir /etc/ssl/nginx
cd /etc/ssl/nginx
# get cert/key
# license
# access secret from secretsmanager
secrets=$(gcloud secrets versions access latest --secret="${secretName}")
# install cert key
echo "setting info from Metadata secret"
# cert
cat << EOF > /etc/ssl/nginx/nginx-repo.crt
$(echo $secrets | jq -r .cert)
EOF
# key
cat << EOF > /etc/ssl/nginx/nginx-repo.key
$(echo $secrets | jq -r .key)
EOF
# get signing key
wget https://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key

# get packages
apt-get install apt-transport-https lsb-release ca-certificates -y
printf "deb https://plus-pkgs.nginx.com/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-plus.list
wget -q -O /etc/apt/apt.conf.d/90nginx https://cs.nginx.com/static/files/90nginx

# install
apt-get update
apt-get install -y nginx-plus nginx-plus-module-njs nginx-plus-module-subs-filter
# get controller token
#echo "Retrieving info from Metadata secret"
#controllerToken=$(gcloud secrets versions access latest --secret="controller-agent")

# connect agent to controller
function register() {
# Check api Ready
ip=${controllerAddress}
#ip="$(gcloud compute instances list --filter name:controller --format json | jq -r .[0].networkInterfaces[0].networkIP)"
zone=$(curl -s -H Metadata-Flavor:Google http://metadata/computeMetadata/v1/instance/zone | cut -d/ -f4)
version="api/v1"
loginUrl="/platform/login"
tokenUrl="/platform/global"
agentUrl="/1.4/install/controller/"
locationsUri="/infrastructure/locations"
payload=$(cat -<<EOF
{
  "credentials": {
        "type": "BASIC",
        "username": "$(echo $secrets | jq -r .cuser)",
        "password": "$(echo $secrets | jq -r .cpass)"
  }
}
EOF
)
zonePayload=$(cat -<<EOF
{
  "metadata": {
    "name": "$zone",
    "displayName": "$zone",
    "description": "$zone",
    "tags": ["gce"]
  },
  "desiredState": {
    "type": "OTHER_LOCATION"
  }
}
EOF
)
if [[ $ip != "none" ]]; then
  count=0
  while [ $count -le 10 ]
  do
  status=$(curl -ksi https://$ip/$version$loginUrl  | grep HTTP | awk '{print $2}')
  if [[ $status == "401" ]]; then
      echo "ready $status"
      echo "wait 1 minute for apis"
      sleep 60
      # login for cookie
      curl -sk --header "Content-Type:application/json"  --data "$payload" --url https://$ip/$version$loginUrl --dump-header /cookie.txt
      cookie=$(cat /cookie.txt | grep Set-Cookie: | awk '{print $2}')
      rm -f /cookie.txt
      # locations api
      tries=0
      while [ $tries -le 10 ]
      do
      locationsApi=$(curl -sik --header "Content-Type:application/json" --header "Cookie: $cookie" --url https://$ip/$version$locationsUri  | grep HTTP | awk '{print $2}')
      if [[ $locationsApi == "200" ]]; then
        #create location
        curl -sk --header "Content-Type:application/json" --header "Cookie: $cookie" --data "$zonePayload" --url https://$ip/$version$locationsUri
        break
      fi
      sleep 6
      done
      # get token
      token=$(curl -sk --header "Content-Type:application/json" --header "Cookie: $cookie" --url https://$ip/$version$tokenUrl | jq -r .desiredState.agentSettings.apiKey)
      # agent install
      curl -ksS -L https://$ip:8443$agentUrl > install.sh && \
      API_KEY="$token" sh ./install.sh --location-name $zone -y
      break
  else
      echo "not ready $status"
      count=$[$count+1]
  fi
  sleep 60
  done
else
  echo "no controller..skipping register"
fi
}
#register
# api
cat > /etc/nginx/conf.d/api.conf <<EOF
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
# oidc
function oidc () {
if [[ "${oidcConfigUrl}" != "none" ]]; then
git clone https://github.com/nginxinc/nginx-openid-connect.git
dir=$PWD
oidcConfigUrl="${oidcConfigUrl}"
cd nginx-openid-connect
cp * /etc/nginx/conf.d/
cd /etc/nginx/conf.d/
chmod +x configure.sh
./configure.sh $oidcConfigUrl
# secrets
clientId=$(echo $secrets | jq -r .clientId)
clientSecret=$(echo $secrets | jq -r .clientSecret)
sed -i "s/my-client-id/$clientId/g" openid_connect_configuration.conf
sed -i "s/my-client-secret/$clientSecret/g" openid_connect_configuration.conf
mv frontend.conf frontend.conf.back
# comment out /api/ endpoint
mv openid_connect.server_conf.conf openid_connect.server_conf.conf.bak
sed -e '/\location \/api\//,+5 s/^/#/' openid_connect.server_conf.conf.bak > openid_connect.server_conf.conf
cd $dir
rm nginx-openid-connect
echo "=== oidc done ===="
else
  echo "no oidcConfigUrl.skipping oidc... "
fi
}
#oidc
# njs
mkdir -p /etc/nginx/njs/

# certs
function cert_bot () {
apt-get install certbot -y
}
mkdir -p /cert
cd /cert
openssl genrsa -des3 -passout pass:1234 -out server.pass.key 2048
openssl rsa -passin pass:1234 -in server.pass.key -out server.key
rm server.pass.key
openssl req -new -key server.key -out server.csr -subj "/C=US/ST=testville/L=testerton/O=Test testing/OU=Test Department/CN=test.example.com"
openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt
# start nginx
systemctl start nginx
# NIM agent
function nim_agent () {
if [[ ${agent} != "none" ]]; then
# instance manager
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
  echo "no nim.skipping agent install"
fi
}
nim_agent
echo "==== done ===="
exit

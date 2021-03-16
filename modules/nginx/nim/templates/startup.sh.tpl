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
apt-get update
apt-get install jq apt-transport-https ca-certificates -y
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
$(echo $secrets | jq -r .cert)
EOF
# key
cat << EOF > /etc/ssl/nginx/nginx-repo.key
$(echo $secrets | jq -r .key)
EOF

echo "==== repos ===="
# add repo with signing key
wget https://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key
apt-get install apt-transport-https lsb-release ca-certificates


printf "deb https://pkgs.nginx.com/instance-manager/debian stable nginx-plus\n" | tee /etc/apt/sources.list.d/instance-manager.list
wget -q -O /etc/apt/apt.conf.d/90pkgs-nginx https://cs.nginx.com/static/files/90pkgs-nginx

apt-get update

# install
echo "==== install ===="
apt-get install -y nginx-manager

function fileInstall {
# file download install
# download form remote source
# unzip
# install
apt-get -y install /home/user/nginx-manager-0.9.0-1_amd64.deb
}

# get localip
echo "=== get ip ==="
local_ipv4="$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" -H "Metadata-Flavor: Google")"
# config
echo "==== config ===="
mkdir -p /var/nginx-manager/
hostname="test.example.com"
cat << EOF > /etc/nginx-manager/nginx-manager.conf
#
# /etc/nginx-manager/nginx-manager.conf
#

# Configuration file for NGINX Instance Manager Server

# bind address for all service ports (default "127.0.0.1")
bind-address: 0.0.0.0
# gRPC service port for agent communication (default "10000")
grpc-port: 10000
# gRPC-gateway service port for API and UI (default "11000")
gateway-port: 11000

# SSL CN or servername for certs
server-name: $hostname
# # path to x.509 certificate file (optional)
#cert: /etc/ssl/nginx-manager/nginx-manager.crt
# # path to x.509 certificate key file (optional)
#key: /etc/ssl/nginx-manager/nginx-manager.key

# set log level (panic, fatal, error, info, debug, trace; default: info) (default "info")
log:
    level: info
    path: /var/log/nginx-manager/
# Metrics default storage path (default "/tmp/metrics") (directory must be already present)
metrics:
    storage-path: /var/nginx-manager/
# Path to license file
license: /etc/nginx-manager/nginx-manager.lic
EOF

echo "==== license ===="
# license
cat << EOF > /etc/nginx-manager/nginx-manager.lic
$(echo $secrets | jq -r .license)
EOF

echo "==== certs ===="
path="/etc/ssl/nginx-manager"
mkdir -p $path
# self signed
echo "====self signed cert===="
openssl genrsa -aes256 -passout pass:1234 -out $${path}/server.pass.key 2048
openssl rsa -passin pass:1234 -in $${path}/server.pass.key -out $${path}/nginx-manager.key
openssl req -new -key $${path}/nginx-manager.key -out $${path}/server.csr -subj "/C=US/ST=testville/L=testerton/O=Test testing/OU=Test Department/CN=$hostname"
openssl x509 -req -sha256 -days 365 -in $${path}/server.csr -signkey $${path}/nginx-manager.key -out $${path}/nginx-manager.crt
rm $${path}/server.pass.key
rm $${path}/server.csr
# from secrets
# # cert
# cat << EOF > /etc/ssl/nginx-manager/nginx-manager.crt
# $(echo $secrets | jq -r .webCert)
# EOF
# # key
# cat << EOF > /etc/ssl/nginx-manager/nginx-manager.key
# $(echo $secrets | jq -r .webKey)
# EOF


function selinux {
# selinux
apt install -y nginx-manager-selinux

semanage port -a -t nginx-manager_port_t -p tcp 10001
semanage port -a -t nginx-manager_port_t -p tcp 11001
}
# start
echo "==== start service ===="
systemctl start nginx-manager
systemctl enable nginx-manager

function NGINX {
secrets=$(gcloud secrets versions access latest --secret="${secretName}")
# cert
cat << EOF > /etc/ssl/nginx/nginx-repo.crt
$(echo $secrets | jq -r .nginxCert)
EOF
# key
cat << EOF > /etc/ssl/nginx/nginx-repo.key
$(echo $secrets | jq -r .nginxKey)
EOF
# get packages
apt-get install apt-transport-https lsb-release ca-certificates -y
printf "deb https://plus-pkgs.nginx.com/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-plus.list
wget -q -O /etc/apt/apt.conf.d/90nginx https://cs.nginx.com/static/files/90nginx
# install nginx-plus
apt-get update
apt-get install -y nginx-plus

# grpc errors map
cat << 'EOF' > /etc/nginx/conf.d/errors.grpc_conf
# Standard HTTP-to-gRPC status code mappings
# Ref: https://github.com/grpc/grpc/blob/master/doc/http-grpc-status-mapping.md
#
error_page 400 = @grpc_internal;
error_page 401 = @grpc_unauthenticated;
error_page 403 = @grpc_permission_denied;
error_page 404 = @grpc_unimplemented;
error_page 429 = @grpc_unavailable;
error_page 502 = @grpc_unavailable;
error_page 503 = @grpc_unavailable;
error_page 504 = @grpc_unavailable;

# NGINX-to-gRPC status code mappings
# Ref: https://github.com/grpc/grpc/blob/master/doc/statuscodes.md
#
error_page 405 = @grpc_internal; # Method not allowed
error_page 408 = @grpc_deadline_exceeded; # Request timeout
error_page 413 = @grpc_resource_exhausted; # Payload too large
error_page 414 = @grpc_resource_exhausted; # Request URI too large
error_page 415 = @grpc_internal; # Unsupported media type;
error_page 426 = @grpc_internal; # HTTP request was sent to HTTPS port
error_page 495 = @grpc_unauthenticated; # Client certificate authentication error
error_page 496 = @grpc_unauthenticated; # Client certificate not presented
error_page 497 = @grpc_internal; # HTTP request was sent to mutual TLS port
error_page 500 = @grpc_internal; # Server error
error_page 501 = @grpc_internal; # Not implemented

# gRPC error responses
# Ref: https://github.com/grpc/grpc-go/blob/master/codes/codes.go
#
location @grpc_deadline_exceeded {
    add_header grpc-status 4;
    add_header grpc-message 'deadline exceeded';
    return 204;
}

location @grpc_permission_denied {
    add_header grpc-status 7;
    add_header grpc-message 'permission denied';
    return 204;
}

location @grpc_resource_exhausted {
    add_header grpc-status 8;
    add_header grpc-message 'resource exhausted';
    return 204;
}

location @grpc_unimplemented {
    add_header grpc-status 12;
    add_header grpc-message unimplemented;
    return 204;
}

location @grpc_internal {
    add_header grpc-status 13;
    add_header grpc-message 'internal error';
    return 204;
}

location @grpc_unavailable {
    add_header grpc-status 14;
    add_header grpc-message unavailable;
    return 204;
}

location @grpc_unauthenticated {
    add_header grpc-status 16;
    add_header grpc-message unauthenticated;
    return 204;
}
EOF
# basic auth
cat << 'EOF' > /etc/nginx/conf.d/nim_basic.conf
# nginx-manager-basicauth.conf
# Proxy UI/API with basic auth to 127.0.0.1 on nginx-manager
# You must create the .htpasswd file and add user/password for this to work
# Include the nginx-manager-upstreams.conf for the proxy_pass to work

server {
    # listen  80;
    listen  444 ssl;

    status_zone nginx-manager_basicauth_https;
    server_name nginx-manager.example.com;

    # Optional log locations
    # access_log /var/log/nginx/nginx-manager-basic-access.log info;
    # error_log /var/log/nginx/nginx-manager-basic-error.log;

    # SSL certificates must be valid for the FQDN and placed in the correct directories
    ssl_certificate         /etc/ssl/nginx-manager/nginx-manager.crt;
    ssl_certificate_key     /etc/ssl/nginx-manager/nginx-manager.key;

    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 24h;
    ssl_session_tickets off;

    ssl_protocols   TLSv1.2 TLSv1.3;
    ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers   off;

    location / {
        proxy_pass https://nginx-manager_servers;
        health_check uri=/swagger-ui/;

        ## Use htpasswd basic auth
        auth_basic "nginx-manager API";
        auth_basic_user_file /etc/nginx/.htpasswd;

        proxy_set_header Authorization "";
        proxy_set_header username       $remote_user;
        proxy_set_header role           $remote_user;
    }

}
EOF
# gui
cat << 'EOF' > /etc/nginx/conf.d/nim_gui.conf
server {
    listen          445 ssl;
    listen      443 http2 ssl;

    access_log      /var/log/nginx/noauth-access.log;
    # error_log     /var/log/nginx/noauth-error.log;

    status_zone     nginx-manager.f5demolab.com_https;
    server_name     nginx-manager.f5demolab.com;

    ssl_certificate             /etc/ssl/nginx-manager/nginx-manager.crt;
    ssl_certificate_key         /etc/ssl/nginx-manager/nginx-manager.key;
    ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;

    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 24h;
    ssl_session_tickets off;

    location / {
        proxy_pass https://nginx-manager_servers/;
            health_check uri=/swagger-ui/;
            proxy_set_header Connection "";
            proxy_http_version 1.1;
    }

}

server {
    # swagger-ui rewrite
    listen      446 ssl;

    access_log /var/log/nginx/swaggerui-access.log;
    # error_log /var/log/nginx/nginx-manager-swaggerui-error.log;

    status_zone nginx-manager.f5demolab.com_https;
    server_name nginx-manager.f5demolab.com;

    ssl_certificate             /etc/ssl/nginx-manager/nginx-manager.crt;
    ssl_certificate_key         /etc/ssl/nginx-manager/nginx-manager.key;
    ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;

    location / {
        proxy_pass  https://nginx-manager_servers/swagger-ui/;
        proxy_set_header Host                   $http_host$server_port;
        proxy_set_header X-Real-IP              $remote_addr;
        proxy_set_header Connection "";
        proxy_http_version 1.1;
    }

    location /api/ {
        proxy_pass https://nginx-manager_servers;
        proxy_set_header Host                   $http_host$server_port;
        proxy_set_header X-Real-IP              $remote_addr;
        proxy_set_header Connection "";
        proxy_http_version 1.1;
    }

    location /ui/ {
        proxy_pass  https://nginx-manager_servers/swagger-ui/;
        proxy_set_header Connection "";
        proxy_http_version 1.1;
    }

}
EOF
# servers
cat << 'EOF' > /etc/nginx/conf.d/nim_upsteams.conf
upstream nginx-manager_servers {
        zone nginx-manager_servers 64k;
        server 127.0.0.1:11000;
}
EOF
# api
cat << 'EOF' > /etc/nginx/conf.d/status_api.conf
# This sample NGINX Plus configuration enables the NGINX Plus API, for live
# activity monitoring and the built-in dashboard, dynamic configuration of
# upstream groups, and key-value stores. Keep in mind that any features
# added to the API in future NGINX Plus releases will be enabled
# automatically by this file.
# Created in May 2018 by NGINX, Inc. for NGINX Plus R14 and later.

# Documentation:
# https://docs.nginx.com/nginx/admin-guide/monitoring/live-activity-monitoring/
# https://www.nginx.com/blog/live-activity-monitoring-nginx-plus-3-simple-steps

# To conform with the conventional configuration scheme, place this file in
# the /etc/nginx/conf.d directory and add an 'include' directive that
# references it in the main configuration file, /etc/nginx/nginx.conf,
# either by name or with a wildcard expression. Then validate and reload
# the configuration, for example with this command:
#
#     nginx -t && nginx -s reload

# Note that additional directives are required in other parts of the
# configuration:
#
# For metrics to be gathered for an HTTP or TCP/UDP virtual server, you must
# include the 'status_zone' directive in its 'server' block. See:
# http://nginx.org/r/status_zone
#
# Similarly, for metrics to be gathered for an upstream server group, you
# must include the 'zone' directive in the 'upstream' block. See:
# http://nginx.org/r/zone
#
# For more information and instructions, see:
# https://docs.nginx.com/nginx/admin-guide/monitoring/live-activity-monitoring#status_data

# We strongly recommend that you restrict access to the NGINX Plus API so
# that only authorized users can view metrics and configuration, change
# configuration, or both. Here are a few options:
#
# (1) Configure your firewall to limit access to port 8080.
#
# (2) Use SSL/TLS client certificates. See:
#    https://docs.nginx.com/nginx/admin-guide/security-controls/terminating-ssl-http/
#
# (3) Enable HTTP Basic authentication (RFC 7617) by uncommenting the
#    'auth_basic*' directives in the 'server' block below. You can add users
#    with an htpasswd generator, which is readily available, or reuse an
#    existing htpasswd file (from an Apache HTTP Server, for example).  See:
#    http://nginx.org/en/docs/http/ngx_http_auth_basic_module.html
#
# (4) Enable access from a defined network and disable it from all others,
#    by uncommenting the 'allow' and 'deny' directives in the 'server' block
#    below and specifying the appropriate network ranges. See:
#    http://nginx.org/en/docs/http/ngx_http_access_module.html
#
# You can create further restrictions on write operations, to distinguish
# between users with read permission and those who can change configuration.
# Uncomment the sample 'limit_except' directive in the 'location api'
# block below. In addition to the HTTP Basic authentication shown, other
# authentication schemes are supported. See:
# http://nginx.org/r/limit_except

server {
    # Conventional port for the NGINX Plus API is 8080
    listen 8080;

#    access_log off; # Don't log access here (test env)
    access_log /var/log/nginx/status-access.log;
    error_log /var/log/nginx/status-error.log;

    # Uncomment to use HTTP Basic authentication; see (3) above
    #auth_basic "NGINX Plus API";
    #auth_basic_user_file /etc/nginx/users;

    # Uncomment to use permissions based on IP address; see (4) above
    #allow 10.0.0.0/8;
    #deny all;

    # Conventional location for accessing the NGINX Plus API
    location /api/ {
        # Enable in read-write mode
        api write=on;

        # Uncomment to further restrict write permissions; see note above
        #limit_except GET {
            #auth_basic "NGINX Plus API";
            #auth_basic_user_file /etc/nginx/admins;
        #}
    }

    # Conventional location of the NGINX Plus dashboard
    location = /dashboard.html {
        root /usr/share/nginx/html;
    }

    # Redirect requests for "/" to "/dashboard.html"
    location / {
        root /usr/share/nginx/html;
        index dashboard.html;
    }

    # Swagger-UI exposure
    location /swagger-ui {
        root /usr/share/nginx/html;
    }

    # Redirect requests for pre-R14 dashboard
    location /status.html {
        return 301 /dashboard.html;
    }
}
EOF
echo "==== nginx-plus done ===="
}

echo "==== done ===="
#systemctl status nginx-manager
exit

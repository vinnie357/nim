FROM ubuntu:focal

# packages
RUN set -x \
&& apt-get update \
&& apt-get install -y \
 jq \
 apt-transport-https \
 lsb-release \
 ca-certificates \
 wget \
 gnupg

#folders
RUN set -x \
&& mkdir /etc/nginx-manager/ \
&& mkdir /etc/ssl/nginx/
# keys & license
COPY licenses/nginx-manager.lic /etc/nginx-manager/nginx-manager.lic
COPY licenses/nginx-manager.crt /etc/ssl/nginx/nginx-repo.crt
COPY licenses/nginx-manager.key /etc/ssl/nginx/nginx-repo.key

# install
RUN set -x \
  && wget https://nginx.org/keys/nginx_signing.key \
  && apt-key add nginx_signing.key \
  && printf "deb https://pkgs.nginx.com/instance-manager/debian stable nginx-plus\n" | tee /etc/apt/sources.list.d/instance-manager.list \
  && wget -q -O /etc/apt/apt.conf.d/90pkgs-nginx https://cs.nginx.com/static/files/90pkgs-nginx \
  # nginx-plus
  && printf "deb https://plus-pkgs.nginx.com/ubuntu `lsb_release -cs` nginx-plus\n" | tee /etc/apt/sources.list.d/nginx-plus.list \
  && wget -q -O /etc/apt/apt.conf.d/90nginx https://cs.nginx.com/static/files/90nginx \
  && apt-get clean \
  && apt-get update \
  && apt-get install -y nginx-manager \
  && apt-get install -y nginx-plus
# NGINX config
RUN rm /etc/nginx/conf.d/default.conf
COPY config/nginx-manager-grpc.conf /etc/nginx/conf.d/nginx-manager-grpc.conf
COPY config/nginx-manager-noauth.conf /etc/nginx/conf.d/nginx-manager-noauth.conf
COPY config/status_api.conf /etc/nginx/conf.d/status_api.conf
COPY config/nginx-manager-upstreams.conf /etc/nginx/conf.d/nginx-manager-upstreams.conf

# config
COPY config/nginx-manager.conf /etc/nginx-manager/nginx-manager.conf
# start


EXPOSE 80 443 10000 11000

STOPSIGNAL SIGQUIT
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

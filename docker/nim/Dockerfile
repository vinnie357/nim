FROM ubuntu:focal
# NGINX MANAGER VERSION
#apt list -a nginx-manager
ENV NIM_VERSION '1.0.1-336280068'
# packages
RUN set -x \
&& apt-get update \
&& apt-get install -y \
 jq \
 apt-transport-https \
 lsb-release \
 ca-certificates \
 wget \
 gnupg \
#folders
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
  && apt-get update \
  && apt-get install -y nginx-manager=${NIM_VERSION}
# config
COPY config/nginx-manager.conf /etc/nginx-manager/nginx-manager.conf
# start

EXPOSE 10000 11000

STOPSIGNAL SIGQUIT

ENTRYPOINT ["nginx-manager"]

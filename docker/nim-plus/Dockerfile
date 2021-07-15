FROM ubuntu:focal
# NGINX MANAGER VERSION
#apt list -a nginx-manager
ENV NIM_VERSION '1.0.1-336280068'
# packages
RUN set -x \
&& apt update \
&& apt install -y \
 jq \
 apt-transport-https \
 lsb-release \
 ca-certificates \
 wget \
 gnupg

#folders
RUN set -x \
&& mkdir /etc/nginx-manager/ \
&& mkdir /etc/ssl/nginx/ \
&& mkdir /var/log/nginx-agent/
# keys & license
COPY licenses/nginx-manager.lic /etc/nginx-manager/nginx-manager.lic
COPY licenses/nginx-manager.crt /etc/ssl/nginx/nginx-repo.crt
COPY licenses/nginx-manager.key /etc/ssl/nginx/nginx-repo.key
# certs
COPY certs/ /etc/ssl/nginx-manager/
# install
RUN set -x \
  && wget https://nginx.org/keys/nginx_signing.key \
  && apt-key add nginx_signing.key \
  && printf "deb https://pkgs.nginx.com/instance-manager/debian stable nginx-plus\n" | tee /etc/apt/sources.list.d/instance-manager.list \
  && wget -q -O /etc/apt/apt.conf.d/90pkgs-nginx https://cs.nginx.com/static/files/90pkgs-nginx \
  # nginx-plus
  && printf "deb https://plus-pkgs.nginx.com/ubuntu `lsb_release -cs` nginx-plus\n" | tee /etc/apt/sources.list.d/nginx-plus.list \
  && wget -q -O /etc/apt/apt.conf.d/90nginx https://cs.nginx.com/static/files/90nginx \
  && apt clean \
  && apt update \
  && apt install -y nginx-manager=${NIM_VERSION} nginx-agent=${NIM_VERSION} \
  && apt install -y nginx-plus
# NGINX config
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx-config/ /etc/nginx/conf.d/
# config
COPY nim-config/nginx-manager.conf /etc/nginx-manager/nginx-manager.conf
COPY nim-config/nginx-agent.conf /etc/nginx-agent/nginx-agent.conf
# start


EXPOSE 80 443 10002

STOPSIGNAL SIGQUIT
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

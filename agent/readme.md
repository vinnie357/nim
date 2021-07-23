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


## customize agent with env variables
```bash
SERVER=mylittleserver.com SERVER_PORT=9999 TAGS=mytag,nginx /usr/sbin/nginx-agent

nginx-agent -h
nginx-agent

Usage:
  nginx-agent [flags]

Flags:
      --api-token string                       set token to auth to commander & metrics service
      --config-dirs string                     set comma-separated list of allowed config directories
  -h, --help                                   help for nginx-agent
      --log-level string                       set log level (panic, fatal, error, info, debug, trace, info) (default "info")
      --log-path string                        set log path and if empty log only to stdout/stderr (default "/var/log/nginx-agent")
      --metadata stringToString                set metadata for the specific instance/machine. Each entry is a key/value pair separated by an equals sign. (default [])
      --metrics-mode string                    set type of nginx metrics collected (nim, controller) (default "nim")
      --metrics-server string                  set gRPC port of the metrics server to connect to
      --metrics-tls-ca string                  set path to CA certificate file
      --metrics-tls-cert string                set path to certificate file
      --metrics-tls-enable                     enable TLS in the setup
      --metrics-tls-key string                 set path to the certificate key file
      --nginx-bin-path string                  set path to the NGINX Binary
      --nginx-exclude-logs string              set comma-separated list of NGINX access log paths to exclude from metrics
      --nginx-metrics-poll-interval duration   set metrics poll interval (default 1s)
      --nginx-pid-path string                  set path to the NGINX PID file
      --nginx-plus-api string                  set NGINX plus status api (see nginx.org/r/api)
      --nginx-stub-status string               set NGINX stub status (see: nginx.org/r/stub_status)
      --server string                          set gRPC port of the server to connect to (default "localhost:10000")
      --tags strings                           set comma-separated list of tags for this specific instance / machine for inventory purposes
      --tls-ca string                          set path to CA certificate file
      --tls-cert string                        set path to certificate file
      --tls-enable                             enable TLS in the setup
      --tls-key string                         set path to the certificate key file
  -v, --version                                version for nginx-agent

```

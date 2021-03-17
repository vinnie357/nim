function info {
echo "==== info ===="
#vars
mgmtIpPublic=$(terraform output --json | jq -r .nim.value.network_interface[0].access_config[0].nat_ip)
mgmtIpPrivate=$(terraform output --json | jq -r  .nim.value.network_interface[0].network_ip)

## outputs
# public
echo "nim_web_public_proxied: https://$mgmtIpPublic"
echo "nim_ssh_public: $mgmtIpPublic"
echo "nim_web_public_direct: http://$mgmtIpPublic:11000"
# private
echo "nim_web_private_proxied: https://$mgmtIpPrivate"
echo "nim_ssh_private: $mgmtIpPrivate"
echo "nim_web_private_direct: http://$mgmtIpPrivate:11000"
}

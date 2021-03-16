function info {
echo "==== info ===="
#vars
mgmtIpPublic=$(terraform output --json | jq -r .nim.value.network_interface[0].access_config[0].nat_ip)
mgmtIpPrivate=$(terraform output --json | jq -r  .nim.value.network_interface[0].network_ip)

# outputs
echo "nim_web_public: https://$mgmtIpPublic:11000"
echo "nim_ssh_public: $mgmtIpPublic"
echo "nim_web_private: https://$mgmtIpPrivate:11000"
}

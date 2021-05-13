function info {
echo "==== info ===="
#vars
#nim
nimMgmtIpPublic=$(terraform output --json | jq -r .nim.value.network_interface[0].access_config[0].nat_ip)
nimmgmtIpPrivate=$(terraform output --json | jq -r  .nim.value.network_interface[0].network_ip)
#docker
dockerMgmtIpPublic=$(terraform output --json | jq -r .docker.value.network_interface[0].access_config[0].nat_ip)
dockerMgmtIpPrivate=$(terraform output --json | jq -r  .docker.value.network_interface[0].network_ip)
#nginxPlusNoAgent
#nginxPlusNoAgentMgmtIpPublic=$(terraform output --json | jq -r .nginxPlusNoAgent.value.network_interface[0].access_config[0].nat_ip)
#nginxPlusNoAgentMgmtIpPrivate=$(terraform output --json | jq -r  .nginxPlusNoAgent.value.network_interface[0].network_ip)
# nginxPlus
nginxPlusMgmtIpPublic=$(terraform output --json | jq -r .nginxPlus.value.network_interface[0].access_config[0].nat_ip)
nginxPlusMgmtIpPrivate=$(terraform output --json | jq -r  .nginxPlus.value.network_interface[0].network_ip)
# nginx
nginxMgmtIpPublic=$(terraform output --json | jq -r .nginx.value.network_interface[0].access_config[0].nat_ip)
nginxMgmtIpPrivate=$(terraform output --json | jq -r  .nginx.value.network_interface[0].network_ip)
## outputs
# public
echo "==== NIM ===="
echo "nim_web_public_proxied: https://$nimMgmtIpPublic"
echo "nim_ssh_public: $nimMgmtIpPublic"
echo "nim_web_public_direct: http://$nimMgmtIpPublic:11000"
# private
echo "nim_web_private_proxied: https://$nimmgmtIpPrivate"
echo "nim_ssh_private: $nimmgmtIpPrivate"
echo "nim_web_private_direct: http://$nimmgmtIpPrivate:11000"
echo "==== docker ===="
echo "ssh_public: $dockerMgmtIpPublic"
# echo "==== nginxPlusNoAgent ===="
# echo "ssh_public: ${nginxPlusNoAgentMgmtIpPublic}"
echo "==== nginxPlus ===="
echo "ssh_public: $nginxPlusMgmtIpPublic"
echo "==== nginxOss ===="
echo "ssh_public: $nginxMgmtIpPublic"
}

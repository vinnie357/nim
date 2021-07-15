# provider
provider "google" {
  project = var.gcpProjectId
  region  = var.gcpRegion
  zone    = var.gcpZone
}
// New Network
module "google_network" {
  source        = "git::https://github.com/f5devcentral/f5-digital-customer-engagement-center//modules/google/terraform/network/min?ref=main"
  gcpProjectId  = var.gcpProjectId
  gcpRegion     = var.gcpRegion
  projectPrefix = var.projectPrefix
  buildSuffix   = var.buildSuffix
}

//NGXIN Instance Manager
module "nim" {
  source           = "../../modules/nim"
  gcpProjectId     = var.gcpProjectId
  projectPrefix    = var.projectPrefix
  adminAccountName = var.adminAccountName
  sshPublicKey     = var.sshPublicKey
  vpc              = module.google_network.vpcs["public"].id
  subnet           = module.google_network.subnets["public"].id
  buildSuffix      = var.buildSuffix
  nimCert          = var.nimCert
  nimKey           = var.nimKey
  nimLicense       = var.nimLicense
  nimVersion       = var.nimVersion
  #nginxPlus       = true
  #nginxCert       = var.nginxCert
  #nginxKey        = var.nginxKey
}

// Nginx plus without agent
module "nginxPlusNoAgent" {
  source               = "git::https://github.com/f5devcentral/f5-digital-customer-engagement-center//modules/google/terraform/nginx-plus?ref=main"
  gcpProjectId         = var.gcpProjectId
  gcpRegion            = var.gcpRegion
  gcpZone              = var.gcpZone
  nginxCert            = var.nginxCert
  nginxKey             = var.nginxKey
  buildSuffix          = var.buildSuffix
  vpc                  = module.google_network.vpcs["public"].id
  subnet               = module.google_network.subnets["public"].id
  adminAccountName     = var.adminAccountName
  adminAccountPassword = var.adminPassword != "" ? var.adminPassword : random_password.password.result
  sshPublicKey         = var.sshPublicKey
  #tags = ["mytag1","mytag2"]
  #sshPublicKey     = file("/home/user/mykey.pub")
  #image = "ubuntu-os-cloud/ubuntu-1804-lts"
  #instanceSize    = "n1-standard-2"
  instanceCount = 5
}
// docker
module "docker" {
  source           = "../../modules/docker"
  gcpProjectId     = var.gcpProjectId
  projectPrefix    = "docker"
  adminAccountName = var.adminAccountName
  sshPublicKey     = var.sshPublicKey
  vpc              = module.google_network.vpcs["public"].id
  subnet           = module.google_network.subnets["public"].id
  buildSuffix      = var.buildSuffix
  nginxCert        = var.nginxCert
  nginxKey         = var.nginxKey
  publicIp         = true
  githubToken      = var.githubToken
  nimAgent         = true
  nimVersion       = var.nimVersion
}
// Nginx plus with agent
module "nginxPlus" {
  source = "../../modules/nginxPlus"
  #source               = "git::https://github.com/f5devcentral/f5-digital-customer-engagement-center//modules/google/terraform/nginx-plus/?ref=main"
  projectPrefix        = "nginxplus"
  gcpProjectId         = var.gcpProjectId
  gcpRegion            = var.gcpRegion
  gcpZone              = var.gcpZone
  nginxCert            = var.nginxCert
  nginxKey             = var.nginxKey
  buildSuffix          = var.buildSuffix
  vpc                  = module.google_network.vpcs["public"].id
  subnet               = module.google_network.subnets["public"].id
  adminAccountName     = var.adminAccountName
  adminAccountPassword = var.adminPassword != "" ? var.adminPassword : random_password.password.result
  sshPublicKey         = var.sshPublicKey
  tags                 = ["nginx", "plus"]
  publicIp             = true
  #sshPublicKey     = file("/home/user/mykey.pub")
  #image = "ubuntu-os-cloud/ubuntu-1804-lts"
  instanceType = "n1-standard-2"
  #nim
  #nimAddress = module.nim.info.nim.value.network_interface[0].network_ip
  nimAgent   = true
  nimVersion = var.nimVersion
  #nimAgentPublicKey = tls_private_key.nim-agent.public_key_openssh
  #oidc
  oidcConfigUrl = var.oidcConfigUrl
  clientId      = var.clientId
  clientSecret  = var.clientSecret
}
// Nginx
module "nginx" {
  source = "../../modules/nginx"
  #source               = "git::https://github.com/f5devcentral/f5-digital-customer-engagement-center//modules/google/terraform/nginx-plus/?ref=main"
  projectPrefix        = "nginxoss"
  gcpProjectId         = var.gcpProjectId
  gcpRegion            = var.gcpRegion
  gcpZone              = var.gcpZone
  nginxCert            = var.nginxCert
  nginxKey             = var.nginxKey
  buildSuffix          = var.buildSuffix
  vpc                  = module.google_network.vpcs["public"].id
  subnet               = module.google_network.subnets["public"].id
  adminAccountName     = var.adminAccountName
  adminAccountPassword = var.adminPassword != "" ? var.adminPassword : random_password.password.result
  sshPublicKey         = var.sshPublicKey
  tags                 = ["nginx", "oss"]
  publicIp             = true
  #sshPublicKey     = file("/home/user/mykey.pub")
  #image = "ubuntu-os-cloud/ubuntu-1804-lts"
  instanceType = "n1-standard-2"
  #nim
  #nimAddress = module.nim.info.nim.value.network_interface[0].network_ip
  nimAgent   = true
  nimVersion = var.nimVersion
  #nimAgentPublicKey = tls_private_key.nim-agent.public_key_openssh
  #oidc
  oidcConfigUrl = var.oidcConfigUrl
  clientId      = var.clientId
  clientSecret  = var.clientSecret
}
// Agent Key
resource "tls_private_key" "agent" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
//tls_private_key.agent.public_key_openssh

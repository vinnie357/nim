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
  source           = "../../modules/nginx/nim"
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
  #nginxPlus       = true
  #nginxCert       = var.nginxCert
  #nginxKey        = var.nginxKey
}

// Nginx
module "nginx" {
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
  instanceCount = 1
}


// Agent Key
resource "tls_private_key" "agent" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
//tls_private_key.agent.public_key_openssh

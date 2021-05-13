# project
variable "projectPrefix" {
  description = "prefix for resources"
  default     = "demo-nginx"
}
variable "gcpZone" {
  description = "zone where gke is deployed"
  default     = "us-east1-b"
}
variable "gcpRegion" {
  description = "region where gke is deployed"
  default     = "us-east1"
}
variable "gcpProjectId" {
  description = "gcp project id"
}
variable "buildSuffix" {
  description = "random build suffix for resources"
  default     = "random-cat"
}
variable "instanceType" {
  default = "n1-standard-4"
}
variable "instanceCount" {
  default = 1
}
variable "tags" {
  description = " instance tags"
  default     = ["nginx"]
}
variable "publicIp" {
  description = "provision a public address or not"
  default     = false
}
variable "image" {
  #source_image = "ubuntu-os-cloud/ubuntu-1804-lts"
  default = "/projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20200810"
}
variable "name" {
  description = "device name"
  default     = "nginx"
}
variable "diskSize" {
  description = "image disk size in GB"
  default     = 20
}
# admin
variable "adminAccountName" {
  description = "admin account"
}
variable "adminAccountPassword" {
  description = "admin account password"
  default     = ""
}
variable "sshPublicKey" {
  description = "body of ssh public key used to access instances"
}
# nginx
variable "nginxKey" {
  description = "key for nginxplus"
}
variable "nginxCert" {
  description = "cert for nginxplus"
}
# controller
variable "controllerAccount" {
  description = "name of controller admin account"
  default     = ""
}
variable "controllerPassword" {
  description = "pass of controller admin account"
  default     = ""
}
variable "controllerAddress" {
  description = "ip4 address of controller to join"
  default     = "none"
}
# nim
variable "nimAddress" {
  description = "ip4 address of nim to join"
  default     = "none"
}
variable "nimAgentPublicKey" {
  description = "ssh public key for access to nim service account"
  default     = "none"
}
variable "nimAgent" {
  description = "install and start the nim agent"
  default     = "none"
}
#okta oidc
variable "oidcConfigUrl" {
  description = "my oidc auto config url https://<name>.-admin.oktapreview.com/.well-known/openid-configuration"
  default     = ""
}
variable "clientId" {
  description = "okta client Id"
  default     = ""
}
variable "clientSecret" {
  description = "okta client secret"
  default     = ""
}
# network
variable "vpc" {
  description = "vpc network to create resource in"
  default     = ""
}
variable "subnet" {
  description = " subnet to create resource in"
  default     = ""
}

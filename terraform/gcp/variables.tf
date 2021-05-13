# random
resource "random_pet" "buildSuffix" {
  keepers = {
    prefix = var.projectPrefix
  }
  separator = "-"
}
resource "random_password" "password" {
  length  = 16
  special = true
}
# project
variable "projectPrefix" {
  description = "prefix for resources"
}
variable "buildSuffix" {
  description = "static suffix for resources"
  default     = "nim-cat"
}
variable "gcpZone" {
  description = "zone where gke is deployed"
}
variable "gcpRegion" {
  description = "region where gke is deployed"
}
variable "gcpProjectId" {
  description = "gcp project id"
}
# admin
variable "adminSourceAddress" {
  description = "admin src address in cidr"
  default     = ["0.0.0.0/0"]
}
variable "adminAccountName" {
  description = "admin account"
}
variable "adminPassword" {
  description = "admin password"
}
variable "sshPublicKey" {
  description = "contents of admin ssh public key"
}
variable "githubToken" {
  description = "github oauth token for private repos"
  default     = ""
}
# nginx
variable "nginxKey" {
  description = "key for nginxplus"
}
variable "nginxCert" {
  description = "cert for nginxplus"
}
# nim
variable "nimKey" {
  description = "Key for NGINX instance Manager"
}
variable "nimCert" {
  description = "Cert for NGINX instance Manager"
}
variable "nimLicense" {
  description = "license for NGINX instance Manager"
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

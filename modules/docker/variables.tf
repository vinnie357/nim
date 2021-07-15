# project
variable "projectPrefix" {
  description = "prefix for resources"
}
variable "gcpZone" {
  description = "zone where resource is deployed"
  default     = "us-east1-b"
}
variable "gcpRegion" {
  description = "region where resource is deployed"
  default     = "us-east2"
}
variable "gcpProjectId" {
  description = "gcp project id"
}
variable "buildSuffix" {
  description = "resource suffix"
}
variable "onboardScript" {
  description = "url for onboard script"
  default     = "none"
}

variable "name" {
  description = "device name"
  default     = "docker"
}

variable "vpc" {
  description = "main vpc"
}
variable "subnet" {
  description = "main vpc subnet"
}
variable "publicIp" {
  description = "provision a public address or not"
  default     = false
}
variable "image" {
  #source_image = "ubuntu-os-cloud/ubuntu-1804-lts"
  default = "/projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20200810"
}
variable "diskSize" {
  description = "image disk size in GB"
  default     = 20
}
variable "instanceType" {
  description = " gce machine type/size"
  default     = "n1-standard-4"
}
variable "tags" {
  description = " instance tags"
  default     = ["dockerplus"]
}
variable "adminAccountName" {
  default = "admin"
}
variable "sshPublicKey" {
  description = "contents of admin ssh public key"
}
variable "githubUser" {
  description = "gitusername to retrive public keys"
  default     = ""
}
variable "githubToken" {
  description = "github oauth token for private repos"
  default     = ""
}
#nginx-plus
variable "nginxKey" {
  description = "key for nginxplus"
  default     = ""
}
variable "nginxCert" {
  description = "cert for nginxplus"
  default     = ""
}
# nim
variable "nimAgent" {
  description = "install and start the nim agent"
  default     = "none"
}
variable "nimVersion" {
  description = "version for NGINX instance Manager"
}
variable  "nimGrpcPort" {
  description = "grpc port for nim"
  default = 10000
}

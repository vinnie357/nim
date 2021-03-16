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
  default     = "nim"
}

variable "vpc" {
  description = "main vpc"
}
variable "subnet" {
  description = "main vpc subnet"
}
variable "publicIp" {
  description = "provision a public address or not"
  default = true
}
variable "deviceImage" {
  description = "gce image name"
  default     = "/projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20200810"
}
variable "diskSize" {
  description = "image disk size in GB"
  default = 20
}
variable "machineType" {
  description = " gce machine type/size"
  default     = "n1-standard-4"
}

variable "adminAccountName" {
  default = "admin"
}
variable "sshPublicKey" {
  description = "contents of admin ssh public key"
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
#nginx-plus
variable "nginxPlus" {
  description = "use nginx-plus to front instance Manager"
  default = false
}
variable "nginxKey" {
  description = "key for nginxplus"
  default = ""
}
variable "nginxCert" {
  description = "cert for nginxplus"
  default = ""
}

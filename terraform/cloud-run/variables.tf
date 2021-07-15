# random
resource "random_pet" "buildSuffix" {
  keepers = {
    prefix = var.projectPrefix
  }
  separator = "-"
}
# project
variable "projectPrefix" {
  description = "prefix for resources"
}
variable "buildSuffix" {
  description = "static suffix for resources"
  default     = "nim-cat"
}
variable "gcpRegion" {
  description = "region where gke is deployed"
}
variable "gcpProjectId" {
  description = "gcp project id"
}
variable "image" {
  description = "container image"
}
variable "serviceAccount" {
  description = "Email address of the service account running the instance"
}

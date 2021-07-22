variable "region" {
  description = "region for resources created by this module"
  default     = "us-east-1"
}
variable "prefix" {
  description = "Prefix for resources created by this module"
  default     = "nim-fargate"
}
variable "images" {
  description = "list of images to make repos for"
  default     = ["nginx-plus", "nginx-plus-ap", "nginx-plus-ap-dos", "nim-plus"]
}

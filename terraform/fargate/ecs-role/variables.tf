#https://github.com/terraform-aws-modules/terraform-aws-atlantis
variable "trusted_principals" {
  description = "A list of principals, in addition to ecs-tasks.amazonaws.com, that can assume the task role"
  type        = list(string)
  default     = []
}

variable "trusted_entities" {
  description = "A list of  users or roles, that can assume the task role"
  type        = list(string)
  default     = []
}

variable "name" {
  description = "Name to use on all resources created (VPC, ALB, etc)"
  type        = string
  default     = "nim"
}
variable "id" {
  description = "random id in hex for suffix"
  type        = string
  default     = ""
}
variable "token" {
  default = ""
}
variable "tags" {
  description = "A map of tags to use on all resources"
  type        = map(string)
  default     = {}
}
variable "permissions_boundary" {
  description = "If provided, all IAM roles will be created with this permissions boundary attached."
  type        = string
  default     = null
}
variable "policies_arn" {
  description = "A list of the ARN of the policies you want to apply"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

variable "app_name" {
  type        = string
  description = "app A record name for route53"
  default     = "example"
}
variable "app_domain" {
  type        = string
  description = "app private dns domain for route53"
  default     = "example.my-project.local"
}
variable "nim_image" {
  description = "nim Docker image to run in the ECS cluster"
  default     = ""
}
variable "nginx_image" {
  description = "nginx Docker image to run in the ECS cluster"
  default     = ""
}
variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  #default     = "ami-04c22ba97a0c063c4"
  #default = "httpd:2.4"
  default = "bkimminich/juice-shop"
}

variable "command" {
  default = ""
  #default = "/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
}
variable "nim_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  #. <-- we will need this value
  #default = 80
  default = 443
}
variable "nginx_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  #. <-- we will need this value
  #default = 80
  default = 443
}
variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  #. <-- we will need this value
  #default = 80
  default = 3000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = "2"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

#
# Variable for the EC2 Key
# Set via CLI or via terraform.tfvars file
#
variable "ec2_key_name" {
  description = "AWS EC2 Key name for SSH access"
}

variable "prefix" {
  description = "Prefix for resources created by this module"
  default     = "nim-fargate"
}
variable "allowed_mgmt_cidr" {
  description = "cidr range for management acl"
  default     = "0.0.0.0/0"
}
variable "allowed_app_cidr" {
  description = "cidr range for app acl"
  default     = "0.0.0.0/0"
}
variable "cidr" {
  description = "cidr range vpc"
  default     = "10.0.0.0/16"
}
variable "region" {
  description = "region for resources created by this module"
  default     = "us-east-1"
}
variable "repo_token" {
  description = "secret for repo access"
  default     = ""
}
variable "nim_public_ip" {
  default = true
}
variable "nginx_public_ip" {
  default = true
}

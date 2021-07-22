provider "aws" {
  region = var.region
}
#
# Create a random id
#
resource "random_id" "id" {
  byte_length = 2
}
// ECR
module "repos" {
  for_each = toset(var.images)
  source   = "./repo"
  image    = each.key
  suffix   = random_id.id.hex
}

locals {
  repos = flatten([
    for index, image in var.images : {
      image = image
      url   = values(module.repos)[index]["repo-url"]
    }
  ])
  repo-map = { for item in local.repos : item.image => item.url }
}

resource "local_file" "ecr-vars" {
  content  = <<EOF
  ${jsonencode({ "repo_list" : local.repo-map })}
  EOF
  filename = "../${path.module}/ecr.auto.tfvars.json"
}

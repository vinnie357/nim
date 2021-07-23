terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  region = var.region
}

#
# Create a random id
#
resource "random_id" "id" {
  byte_length = 2
}
locals {
  repos = var.repo_list
}

resource "aws_ecs_cluster" "nim-ecs-cluster" {
  name = format("nim-ecs-cluster-%s", random_id.id.hex)
}

#https://aws.amazon.com/blogs/compute/securing-credentials-using-aws-secrets-manager-with-aws-fargate/
module "nim-role" {
  source = "./ecs-role"
  name   = format("nim-%s", random_id.id.hex)
  id     = random_id.id.hex
  token  = var.repo_token
}

module "nginx-role" {
  source = "./ecs-role"
  name   = format("nginx-%s", random_id.id.hex)
  id     = random_id.id.hex
  token  = var.repo_token
}
#https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
// CPU value	Memory value (MiB)
// 256 (.25 vCPU)	512 (0.5GB), 1024 (1GB), 2048 (2GB)
// 512 (.5 vCPU)	1024 (1GB), 2048 (2GB), 3072 (3GB), 4096 (4GB)
// 1024 (1 vCPU)	2048 (2GB), 3072 (3GB), 4096 (4GB), 5120 (5GB), 6144 (6GB), 7168 (7GB), 8192 (8GB)
// 2048 (2 vCPU)	Between 4096 (4GB) and 16384 (16GB) in increments of 1024 (1GB)
// 4096 (4 vCPU)	Between 8192 (8GB) and 30720 (30GB) in increments of 1024 (1GB)
resource "aws_ecs_task_definition" "nim-plus" {
  depends_on               = [module.nim-role]
  family                   = "nim"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 4096
  memory                   = 8192
  execution_role_arn       = module.nim-role.role_arn
  task_role_arn            = module.nim-role.role_arn
  container_definitions    = <<DEFINITION
  [
    {
      "cpu": ${var.nim_cpu},
      "image": "${local.repos[var.nim_image]}",
      "memory": ${var.nim_memory},
      "name": "nim",
      "networkMode": "awsvpc",
      "portMappings": [
        {
          "containerPort": ${var.nginx_port},
          "hostPort": ${var.nginx_port}
        }
      ]
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "nim-plus" {
  name            = format("nim-plus-service%s", random_id.id.hex)
  cluster         = aws_ecs_cluster.nim-ecs-cluster.id
  task_definition = aws_ecs_task_definition.nim-plus.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.private-a.id]
    security_groups  = [aws_security_group.fargate_sg.id]
    assign_public_ip = var.nim_public_ip
  }
  service_registries {
    registry_arn = aws_service_discovery_service.example.arn
  }

}

resource "aws_ecs_task_definition" "nginx-plus" {
  depends_on               = [module.nginx-role]
  family                   = "nginx-plus"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096
  execution_role_arn       = module.nim-role.role_arn
  task_role_arn            = module.nim-role.role_arn
  container_definitions    = <<DEFINITION
  [
    {
      "cpu": ${var.fargate_cpu},
      "image": "${local.repos[var.nginx_image]}",
      "memory": ${var.fargate_memory},
      "name": "nginx-plus",
      "networkMode": "awsvpc",
      "portMappings": [
        {
          "containerPort": ${var.nginx_port},
          "hostPort": ${var.nginx_port}
        }
      ]
    },
    {
      "cpu": ${var.fargate_cpu},
      "image": "${var.app_image}",
      "memory": ${var.fargate_memory},
      "name": "app",
      "networkMode": "awsvpc",
      "portMappings": [
        {
          "containerPort": ${var.app_port},
          "hostPort": ${var.app_port}
        }
      ]
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "nginx-plus-a" {
  name            = format("nginx-plus-service-a%s", random_id.id.hex)
  cluster         = aws_ecs_cluster.nim-ecs-cluster.id
  task_definition = aws_ecs_task_definition.nginx-plus.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.private-a.id]
    security_groups  = [aws_security_group.fargate_sg.id]
    assign_public_ip = var.nginx_public_ip
  }
  service_registries {
    registry_arn = aws_service_discovery_service.nginx.arn
  }

}

resource "aws_ecs_service" "nginx-plus-b" {
  name            = format("nginx-plus-service-b%s", random_id.id.hex)
  cluster         = aws_ecs_cluster.nim-ecs-cluster.id
  task_definition = aws_ecs_task_definition.nginx-plus.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.private-b.id]
    security_groups  = [aws_security_group.fargate_sg.id]
    assign_public_ip = var.nginx_public_ip
  }
  service_registries {
    registry_arn = aws_service_discovery_service.nginx.arn
  }

}

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
resource "aws_ecr_repository" "nim-plus" {
  name                 = format("nim-plus-%s", random_id.id.hex)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecr_repository" "nginx-plus" {
  name                 = format("nginx-plus-%s", random_id.id.hex)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecr_repository_policy" "nim-plus-policy" {
  depends_on = [
    aws_ecr_repository.nim-plus,
  ]
  repository = aws_ecr_repository.nim-plus.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the demo repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

resource "aws_ecr_repository_policy" "nginx-policy" {
  depends_on = [
    aws_ecr_repository.nginx-plus,
  ]
  repository = aws_ecr_repository.nginx-plus.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the demo repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

resource "local_file" "ecr-vars" {
  content  = <<EOF
     nim_image         = "${aws_ecr_repository.nim-plus.repository_url}"
     nginx_image       = "${aws_ecr_repository.nginx-plus.repository_url}"
    EOF
  filename = "../${path.module}/ecr.auto.tfvars"
}

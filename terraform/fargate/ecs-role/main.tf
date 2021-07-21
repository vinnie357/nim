#https://github.com/terraform-aws-modules/terraform-aws-atlantis
locals {
    tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
  )
}
data "aws_iam_policy_document" "ecs_tasks" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = compact(distinct(concat(["ecs-tasks.amazonaws.com"], var.trusted_principals)))
    }

    dynamic "principals" {
      for_each = length(var.trusted_entities) > 0 ? [true] : []

      content {
        type        = "AWS"
        identifiers = var.trusted_entities
      }
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {

  name                 = format("%s-ecs_task_execution-%s", var.name,var.id)
  assume_role_policy   = data.aws_iam_policy_document.ecs_tasks.json
  permissions_boundary = var.permissions_boundary

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  count = length(var.policies_arn)

  role       = aws_iam_role.ecs_task_execution.id
  policy_arn = element(var.policies_arn, count.index)
}

resource "aws_secretsmanager_secret" "repo_secret" {
  name        = format("%s-reposecret-%s", var.name,var.id)
  description = "nginx_secret_crt"
}

resource "aws_secretsmanager_secret_version" "repo_secret" {
  secret_id     = aws_secretsmanager_secret.repo_secret.id
  secret_string = jsonencode({ username : "AWS", password : var.token })
}

# ref: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html
data "aws_iam_policy_document" "ecs_task_access_secrets" {
  statement {
    effect = "Allow"

    resources = flatten([
      aws_secretsmanager_secret.repo_secret.*.arn
    ])

    actions = [
      "secretsmanager:GetSecretValue"
    ]
  }
}

// data "aws_iam_policy_document" "ecs_task_access_secrets_with_kms" {

//   source_json = data.aws_iam_policy_document.ecs_task_access_secrets.json

//   statement {
//     sid       = "AllowKMSDecrypt"
//     effect    = "Allow"
//     actions   = ["kms:Decrypt"]
//     resources = [var.ssm_kms_key_arn]
//   }
// }

resource "aws_iam_role_policy" "ecs_task_access_secrets" {

  name = "ECSTaskAccessSecretsPolicy"

  role = aws_iam_role.ecs_task_execution.id

  policy = element(
    compact(
      concat(
        // data.aws_iam_policy_document.ecs_task_access_secrets_with_kms.*.json,
        data.aws_iam_policy_document.ecs_task_access_secrets.*.json,
      ),
    ),
    0,
  )
}

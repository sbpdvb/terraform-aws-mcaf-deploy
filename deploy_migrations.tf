data "aws_iam_policy_document" "codebuild_deploy_migrations_policy" {
  statement {
    actions = [
      "s3:Get*"
    ]
    resources = [
      "arn:aws:s3:::${local.usecase_bucket}",
      "arn:aws:s3:::${local.usecase_bucket}/*"
    ]
  }

  statement {
    actions = [
      "ec2:CreateNetworkInterfacePermission",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/migrations/*",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.opco}/rds/${local.rds_usecase_username_ro}/password",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.opco}/rds/${local.rds_usecase_username_rw}/password"
    ]
  }

  dynamic "statement" {
    for_each = {
      for k, v in var.environment_variables : k => v if v.type == "PARAMETER_STORE"
    }

    content {
      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ]
      resources = [
        "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${statement.value.value}"
      ]
    }
  }
}

module "codebuild_deploy_migrations_role" {
  source                = "github.com/schubergphilis/terraform-aws-mcaf-role?ref=v0.3.1"
  name                  = "${local.usecase}-deploy-migrations"
  create_policy         = true
  principal_identifiers = ["codebuild.amazonaws.com"]
  principal_type        = "Service"
  role_policy           = data.aws_iam_policy_document.codebuild_deploy_migrations_policy.json
  tags                  = var.tags
}

resource "aws_codebuild_project" "deploy_migrations" {
  name         = "${local.usecase}-deploy-migrations"
  service_role = module.codebuild_deploy_migrations_role.arn
  tags         = var.tags

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_migrations != null ? var.buildspec_migrations : file("${path.module}/buildspec/migrations.yaml")
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      group_name = "${local.usecase}-deploy-logs"
      status     = "ENABLED"
    }
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name  = "AWS_ACCOUNTID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "OPCO"
      value = var.opco
    }

    environment_variable {
      name  = "SITE_CODE"
      value = var.site_code
    }

    environment_variable {
      name  = "RDS_USECASE_SCHEMA"
      value = local.rds_usecase_schema
    }

    environment_variable {
      name  = "RDS_USECASE_USERNAME_RO"
      value = local.rds_usecase_username_ro
    }

    environment_variable {
      name  = "RDS_USECASE_USERNAME_RW"
      value = local.rds_usecase_username_rw
    }

    environment_variable {
      name  = "USECASE"
      value = local.usecase
    }

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.key
        type  = environment_variable.value.type
        value = environment_variable.value.value
      }
    }
  }

  vpc_config {
    subnets = var.subnet_ids
    vpc_id  = data.aws_subnet.private.vpc_id

    security_group_ids = [
      data.aws_security_group.aurora.id
    ]
  }
}

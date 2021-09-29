data "aws_iam_policy_document" "codebuild_deploy_docker_policy" {
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
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
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
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/gemfury/ro_token"
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

module "codebuild_deploy_docker_role" {
  source                = "github.com/schubergphilis/terraform-aws-mcaf-role?ref=v0.3.1"
  name                  = "${local.usecase}-deploy-docker"
  create_policy         = true
  role_policy           = data.aws_iam_policy_document.codebuild_deploy_docker_policy.json
  principal_type        = "Service"
  principal_identifiers = ["codebuild.amazonaws.com"]
  tags                  = var.tags
}

resource "aws_codebuild_project" "deploy_docker" {
  name         = "${local.usecase}-deploy-docker"
  service_role = module.codebuild_deploy_docker_role.arn
  tags         = var.tags

  source {
    buildspec = var.buildspec_docker != null ? var.buildspec_docker : file("${path.module}/buildspec/docker.yaml")
    type      = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
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
      name  = "GEMFURY_RO_TOKEN"
      type  = "PARAMETER_STORE"
      value = "/gemfury/ro_token"
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

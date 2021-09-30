data "aws_iam_policy_document" "codebuild_deploy_functions_policy" {
  statement {
    actions = [
      "s3:List*",
      "s3:Get*",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${local.usecase}",
      "arn:aws:s3:::${local.usecase}/*",
      "arn:aws:s3:::${local.usecase_bucket}",
      "arn:aws:s3:::${local.usecase_bucket}/*"
    ]
  }

  statement {
    actions = [
      "ssm:GetParameters"
    ]
    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/gemfury/ro_token",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/github/token",
    ]
  }

  statement {
    actions = [
      "lambda:CreateAlias",
      "lambda:CreateFunction",
      "lambda:ListAliases",
      "lambda:ListFunctions",
      "lambda:PublishVersion",
      "lambda:UpdateAlias",
      "lambda:UpdateFunctionCode",
    ]
    resources = ["*"]
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
      "greengrass:CreateDeployment",
      "greengrass:GetCoreDefinitionVersion",
      "greengrass:GetGroup",
      "greengrass:GetGroupVersion",
      "greengrass:ListGroups",
      "iam:PassRole"
    ]
    resources = ["*"]
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

module "codebuild_deploy_functions_role" {
  source                = "github.com/schubergphilis/terraform-aws-mcaf-role?ref=v0.3.2"
  name                  = "${local.usecase}-deploy-functions"
  create_policy         = true
  principal_identifiers = ["codebuild.amazonaws.com"]
  principal_type        = "Service"
  role_policy           = data.aws_iam_policy_document.codebuild_deploy_functions_policy.json
  tags                  = var.tags
  permissions_boundary  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionsBoundary"
}

resource "aws_codebuild_project" "deploy_functions" {
  name         = "${local.usecase}-deploy-functions"
  service_role = module.codebuild_deploy_functions_role.arn
  tags         = var.tags

  source {
    buildspec = var.buildspec_functions != null ? var.buildspec_functions : file("${path.module}/buildspec/functions.yaml")
    type      = "CODEPIPELINE"
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
      name  = "GITHUB_TOKEN"
      type  = "PARAMETER_STORE"
      value = "/github/token"
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
}

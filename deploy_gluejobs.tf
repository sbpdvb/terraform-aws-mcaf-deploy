data "aws_iam_policy_document" "codebuild_deploy_gluejobs_policy" {
  statement {
    actions = [
      "s3:List*",
      "s3:Get*",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${local.deployment_bucket}",
      "arn:aws:s3:::${local.deployment_bucket}/*"
    ]
  }

  statement {
    actions = [
      "glue:*"
    ]
    resources = ["*"]
  }
  dynamic "statement" {
    for_each = var.gluejob_iam_role_arn == "" ? [] : [1]
    content {
      actions = [
        "iam:PassRole"
      ]
      resources = ["${var.gluejob_iam_role_arn}"]
    }
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

module "codebuild_deploy_gluejobs_role" {
  source                = "github.com/schubergphilis/terraform-aws-mcaf-role?ref=v0.3.2"
  name                  = "${var.workload_name}-deploy-gluejobs"
  create_policy         = true
  principal_identifiers = ["codebuild.amazonaws.com"]
  principal_type        = "Service"
  role_policy           = data.aws_iam_policy_document.codebuild_deploy_gluejobs_policy.json
  tags                  = var.tags
  permissions_boundary  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionsBoundary"
}

resource "aws_codebuild_project" "deploy_gluejobs" {
  name         = "${var.workload_name}-deploy-gluejobs"
  service_role = module.codebuild_deploy_gluejobs_role.arn
  tags         = var.tags

  source {
    buildspec = var.buildspec_gluejobs != null ? var.buildspec_gluejobs : file("${path.module}/buildspec/gluejobs.yaml")
    type      = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      group_name = "${var.workload_name}-deploy-gluejobs-logs"
      status     = "ENABLED"
    }
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name  = "AWS_ACCOUNTID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "WORKLOAD_ENVIRONMENT"
      value = var.workload_environment
    }
    environment_variable {
      name  = "WORKLOAD_NAME"
      value = var.workload_name
    }
    environment_variable {
      name  = "WORKLOAD_REPOSITORY"
      value = var.workload_repository
    }
    environment_variable {
      name  = "WORKLOAD_VERSION"
      value = var.workload_version
    }

    dynamic "environment_variable" {
      for_each = var.gluejob_iam_role_arn == "" ? [] : [1]
      content {
        name  = "GLUE_IAM_ROLE"
        value = var.gluejob_iam_role_arn
      }
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

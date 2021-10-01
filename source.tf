data "aws_iam_policy_document" "codebuild_source_policy" {
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
}

module "codebuild_role" {
  source                = "github.com/schubergphilis/terraform-aws-mcaf-role?ref=v0.3.2"
  name                  = "${var.workload_name}-source"
  create_policy         = true
  principal_identifiers = ["codebuild.amazonaws.com"]
  principal_type        = "Service"
  role_policy           = data.aws_iam_policy_document.codebuild_source_policy.json
  tags                  = var.tags
  permissions_boundary  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionsBoundary"
}

resource "aws_codebuild_project" "source" {
  name         = "${var.workload_name}-source"
  description  = "Download source code of ${var.workload_name} and trigger deployment"
  service_role = module.codebuild_role.arn
  tags         = var.tags

  source {
    buildspec       = file("${path.module}/buildspec/source.yaml")
    git_clone_depth = 1
    location        = "https://github.com/${var.workload_repository}"
    type            = "GITHUB"
  }

  artifacts {
    location = module.deployment_bucket.name
    type     = "S3"
  }

  logs_config {
    cloudwatch_logs {
      group_name = "${var.workload_name}-deploy-logs"
      status     = "ENABLED"
    }
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    type                        = "LINUX_CONTAINER"
  }
}

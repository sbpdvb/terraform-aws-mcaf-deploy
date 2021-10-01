data "aws_iam_policy_document" "codepipeline_role_policy" {
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
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = ["*"]
  }
}


module "codepipeline_role" {
  source                = "github.com/schubergphilis/terraform-aws-mcaf-role?ref=v0.3.2"
  name                  = "${var.workload_name}-pipeline"
  create_policy         = true
  principal_identifiers = ["codepipeline.amazonaws.com"]
  principal_type        = "Service"
  role_policy           = data.aws_iam_policy_document.codepipeline_role_policy.json
  tags                  = var.tags
  permissions_boundary  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PermissionsBoundary"
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.workload_name}-workload"
  role_arn = module.codepipeline_role.arn
  tags     = var.tags

  artifact_store {
    location = module.deployment_bucket.name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      output_artifacts = ["source_output"]
      owner            = "AWS"
      provider         = "S3"
      version          = "1"

      configuration = {
        S3Bucket    = module.deployment_bucket.name
        S3ObjectKey = "${var.workload_name}/workload.zip"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Functions"
      category        = "Build"
      input_artifacts = ["source_output"]
      owner           = "AWS"
      provider        = "CodeBuild"
      run_order       = 2
      version         = "1"

      configuration = {
        ProjectName = "${var.workload_name}-deploy-functions"
      }
    }
  }
}

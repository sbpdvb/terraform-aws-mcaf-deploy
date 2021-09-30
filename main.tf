locals {
  rds_usecase_schema      = "${var.site_code}_${var.usecase_code}"
  rds_usecase_username_ro = "${var.site_code}_${var.usecase_code}_ro"
  rds_usecase_username_rw = "${var.site_code}_${var.usecase_code}_rw"
  usecase                 = "${var.site_code}-${var.usecase_code}"
  usecase_bucket          = "${local.usecase}-deploy"
  usecase_repository      = var.usecase_repository != null ? var.usecase_repository : "dvb-${var.usecase_code}"
  usecase_version         = trimspace(var.usecase_version)
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "github_release" "default" {
  repository  = local.usecase_repository
  owner       = var.usecase_repository_owner
  retrieve_by = "tag"
  release_tag = local.usecase_version
}

data "aws_subnet" "private" {
  id = var.subnet_ids[0]
}

resource "null_resource" "trigger" {
  triggers = {
    release_id = data.github_release.default.id
  }

  provisioner "local-exec" {
    command = "${path.module}/bin/trigger -project-name=${local.usecase} -source-version=${local.usecase_version}"
  }

  depends_on = [
    aws_codebuild_project.deploy_docker,
    aws_codebuild_project.deploy_frontend,
    aws_codebuild_project.deploy_functions,
    aws_codebuild_project.deploy_migrations,
    aws_codebuild_project.deploy_streams,
    aws_codebuild_project.source,
    aws_codepipeline.codepipeline,
  ]
}
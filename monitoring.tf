module "monitors" {
  source           = "github.com/schubergphilis/terraform-datadog-mcaf-monitor?ref=v0.3.0"
  dashboard        = "https://app.datadoghq.com/dashboard/epb-6qp-64r?&tpl_var_opco=${var.opco}"
  evaluation_delay = 900
  notify_no_data   = false
  notifiers        = var.alert_notifiers
  tag_map          = var.tags

  monitors = {
    deploy_docker = {
      name       = "${aws_codebuild_project.deploy_docker.name} build failures"
      message    = "Build of ${aws_codebuild_project.deploy_docker.name} failed"
      query      = "sum(last_15m):sum:aws.codebuild.failed_builds{projectname:${aws_codebuild_project.deploy_docker.name}}.as_count() >=1"
      thresholds = { ok = 0, critical = 1 }
      type       = "query alert"
    }

    deploy_frontend = {
      name       = "${aws_codebuild_project.deploy_frontend.name} build failures"
      message    = "Build of ${aws_codebuild_project.deploy_frontend.name} failed"
      query      = "sum(last_15m):sum:aws.codebuild.failed_builds{projectname:${aws_codebuild_project.deploy_frontend.name}}.as_count() >=1"
      thresholds = { ok = 0, critical = 1 }
      type       = "query alert"
    }

    deploy_functions = {
      name       = "${aws_codebuild_project.deploy_functions.name} build failures"
      message    = "Build of ${aws_codebuild_project.deploy_functions.name} failed"
      query      = "sum(last_15m):sum:aws.codebuild.failed_builds{projectname:${aws_codebuild_project.deploy_functions.name}}.as_count() >=1"
      thresholds = { ok = 0, critical = 1 }
      type       = "query alert"
    }

    deploy_migrations = {
      name       = "${aws_codebuild_project.deploy_migrations.name} build failures"
      message    = "Build of ${aws_codebuild_project.deploy_migrations.name} failed"
      query      = "sum(last_15m):sum:aws.codebuild.failed_builds{projectname:${aws_codebuild_project.deploy_migrations.name}}.as_count() >=1"
      thresholds = { ok = 0, critical = 1 }
      type       = "query alert"
    }

    deploy_streams = {
      name       = "${aws_codebuild_project.deploy_streams.name} build failures"
      message    = "Build of ${aws_codebuild_project.deploy_streams.name} failed"
      query      = "sum(last_15m):sum:aws.codebuild.failed_builds{projectname:${aws_codebuild_project.deploy_streams.name}}.as_count() >=1"
      thresholds = { ok = 0, critical = 1 }
      type       = "query alert"
    }
  }
}

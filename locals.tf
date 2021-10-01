locals {
  deployment_bucket         = "${var.workload_name}-deploy"
  workload_repository_parts = split("/", var.workload_repository)
  workload_version          = trimspace(var.workload_version)
}

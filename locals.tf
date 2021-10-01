locals {
  deployment_bucket         = "${var.workload_name}-deploy"
  workload_repository_parts = split("/", var.workload_repository)
  workload_version          = var.workload_version != null ? trimspace(var.workload_version) : null
}

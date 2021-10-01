locals {
  deployment_bucket = "${var.workload_name}-deploy"
  workload_version  = trimspace(var.workload_version)
}

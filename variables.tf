variable "buildspec_functions" {
  type        = string
  default     = null
  description = "Custom buildspec file for deploying functions"
}

variable "buildspec_gluejobs" {
  type        = string
  default     = null
  description = "Custom buildspec file for deploying gluejobs"
}

variable "environment_variables" {
  type = map(
    object({
      type  = string
      value = string
    })
  )
  default     = {}
  description = "Environment variables for the build and deploy scripts. Valid values for type: PARAMETER_STORE, PLAINTEXT."
}

variable "gluejob_iam_role_arn" {
  type        = string
  default     = ""
  description = "IAM Role used to deploy Glue Jobs"
}

variable "logging" {
  type = object({
    target_bucket = string
    target_prefix = string
  })
  default     = null
  description = "Logging configuration"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The subnet ID list used for deployment"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
}

variable "workload_environment" {
  type        = string
  description = "The environment this workload is being deployed in"
}

variable "workload_name" {
  type        = string
  description = "The workload name"
}

variable "workload_repository" {
  type        = string
  description = "Repository full name of the GitHub repository"
}

variable "workload_version" {
  type        = string
  description = "The version of the workload to deploy"
}

variable "buildspec_functions" {
  type        = string
  default     = null
  description = "Custom buildspec file for deploying functions"
}

variable "buildspec_streams" {
  type        = string
  default     = null
  description = "Custom buildspec file for deploying streams"
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

variable "subnet_ids" {
  type        = list(string)
  description = "The subnet ID list used for deployment"
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
  default     = null
  description = "The version of the workload to deploy"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
}

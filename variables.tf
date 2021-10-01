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

variable "workload_name" {
  type        = string
  description = "The workload name"
}

variable "workload_repository" {
  type        = string
  description = "Repository name of the GitHub repository"
}

variable "workload_repository_owner" {
  type        = string
  default     = "schubergphilis"
  description = "The GitHub repository owner of the workload to be deployed"
}

variable "workload_version" {
  type        = string
  description = "The version of the workload to deploy"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
}

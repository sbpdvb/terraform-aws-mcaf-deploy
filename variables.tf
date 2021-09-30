variable "alert_notifiers" {
  type        = list(string)
  default     = ["@mon-heineken@schubergphilis.com", "@opsgenie-heineken"]
  description = "Notifiers of the codebuild failure alerts"
}

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

variable "usecase_environment" {
  type        = string
  description = "The usecase environment"
}

variable "usecase_name" {
  type        = string
  description = "The usecase name"
}

variable "usecase_repository" {
  type        = string
  default     = null
  description = "Optional repository name if the GitHub repository has a non-default name"
}

variable "usecase_repository_owner" {
  type        = string
  default     = "schubergphilis"
  description = "The GitHub repository owner of the usecase to be deployed"
}

variable "usecase_version" {
  type        = string
  description = "The version of the usecase to deploy"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
}

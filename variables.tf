variable "opco" {
  type        = string
  description = "The operational company"
}

variable "site_code" {
  type        = string
  description = "The site code"
}

variable "alert_notifiers" {
  type        = list(string)
  default     = ["@mon-heineken@schubergphilis.com", "@opsgenie-heineken"]
  description = "Notifiers of the codebuild failure alerts"
}

variable "buildspec_docker" {
  type        = string
  default     = null
  description = "Custom buildspec file for deploying docker"
}

variable "buildspec_frontend" {
  type        = string
  default     = null
  description = "Custom buildspec file for deploying frontend"
}

variable "buildspec_functions" {
  type        = string
  default     = null
  description = "Custom buildspec file for deploying functions"
}

variable "buildspec_migrations" {
  type        = string
  default     = null
  description = "Custom buildspec file for deploying database migrations"
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

variable "restore_kinesis_state" {
  type        = bool
  default     = true
  description = "Option to restore the Kinesis Analytics state"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The subnet ID list used for deployment"
}

variable "usecase_code" {
  type        = string
  description = "The usecase code"
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

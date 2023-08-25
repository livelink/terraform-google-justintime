
variable "gcp_service_list" {
  description = "The list of apis necessary for the project"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "iap.googleapis.com",
    "run.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "secretmanager.googleapis.com",
  ]
}


# Deployment Variables
variable "container_image" {
  type        = string
  description = "Container registry path for the Just In Time application"
}

variable "project" {
  type        = string
  description = "The project ID where the Just In Time application is deployed into"
}

variable "auth_consent_screen_support_email" {
  type        = string
  description = "Support email for IAP"
}

variable "dns_name" {
  type        = string
  description = "Dns name of the Just In Time application"
}

variable "region" {
  type        = string
  description = "The region where the Just In Time application is deployed into"
}

variable "iap_access_principle" {
  type        = string
  description = "Who is able to access the IAP"
}

variable "application_name" {
  type        = string
  description = "The name of the application"
}

variable "allow_unauthenticated_invocations" {
  type        = bool
  description = "Opens the jit http endpoint up to unauthenticated users. This is ill-advised."
  default     = false
}

variable "maximum_duration" {
  type        = number
  description = "Sets the longest duration that a user can request"
  default     = 60
}

variable "justification_hint" {
  type        = string
  description = "Hint provided to the user when selecting why they are asking for the role"
  default     = "Bug or case number"
}

variable "justification_pattern" {
  type        = string
  description = "Regex pattern that justification must match"
  default     = ".*"
}

## Scope Variables
variable "scope_type" {
  type        = string
  description = "The level in google cloud hierarchy the application sits"
  validation {
    condition     = contains(["organizations", "folders", "projects"], var.scope_type)
    error_message = "Valid values for variable: scope_type are (organizations, folders, projects)."
  }
}

variable "acting_project" {
  type        = string
  description = "Project ID when scope_type set to 'projects'"
  default     = ""
}


variable "acting_folder" {
  type        = string
  description = "Folder ID when scope_type set to 'folders'"
  default     = ""
}


variable "acting_organization" {
  type        = string
  description = "Organization ID when scope_type set to 'organizations'"
  default     = ""
}



it makes sense to keep the IAM in a central place. 
Here are examples of the resources as they should be to deploy the correct conditions. 

- make sure to check iap_access_principle as this is the list of users who can access the app?
  - maybe it's everyone? 

```terraform

#  no_approval_required_roles = ["roles/container.admin"]

# IAM binding variables - this might be better with other bindings.

variable "no_approval_required_roles" {
  type        = list(any)
  default     = []
  description = "List of roles that should be requestable via JIT solution"
}

variable "approval_required_roles" {
  type        = list(any)
  default     = []
  description = "List of roles that should be requestable via JIT solution"
}

```



```terraform
resource "google_project_iam_member" "no_approval_required" {
  count = length(var.no_approval_required_roles) > 0 ? 1 : 0

  role    = var.no_approval_required_roles[count.index]
  member  = var.iap_access_principle
  project = var.project
  condition {
    title      = "Eligible for JIT access - automatic"
    expression = "has({}.jitAccessConstraint)"
  }
}

# Approval required bindings

resource "google_project_iam_member" "approval_required" {
  count = length(var.approval_required_roles) > 0 ? 1 : 0

  role    = var.approval_required_roles[count.index]
  member  = var.iap_access_principle
  project = var.project
  condition {
    title      = "Eligible for JIT access - approval"
    expression = "has({}.multiPartyApprovalConstraint)"
  }
}

```
locals {
  # for a clean translation when using terragrunt
  deployment_project = var.project

  # selecting scope_id dependent on provided scope_type
  project_scope_id = var.scope_type == "projects" ? var.acting_project : ""
  folder_scope_id = var.scope_type == "folders" ? var.acting_folder : ""
  org_scope_id = var.scope_type == "organizations" ? var.acting_organization : ""
  scope_id         = coalesce(local.project_scope_id, local.folder_scope_id, local.org_scope_id)

  # Roles required to view assets and to apply changes to iam configuration.
  app_roles        = [ "roles/iam.securityAdmin", "roles/cloudasset.viewer" ]
}

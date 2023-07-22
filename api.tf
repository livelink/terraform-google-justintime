resource "google_project_service" "default" {
  for_each = toset(var.gcp_service_list)
  project  = local.deployment_project
  service  = each.key
}

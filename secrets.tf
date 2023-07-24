# creates the secret for the workspace token for multi party approval
resource "google_secret_manager_secret" "default" {
  count     = var.enable_multi_party_approval == true ? 1 : 0
  project   = local.deployment_project
  secret_id = "${var.application_name}-workspace-token"
  replication {
    automatic = true
  }
}

# applies the provided secret data to the secret
resource "google_secret_manager_secret_version" "default" {
  count       = var.enable_multi_party_approval == true ? 1 : 0
  secret      = google_secret_manager_secret.default[0].id
  secret_data = var.smtp_user_workspace_token
}
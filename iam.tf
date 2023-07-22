# Who can access the application it might be better to also keep these alongside your organizations IAM
resource "google_iap_web_backend_service_iam_member" "iap_http_access" {
  project             = local.deployment_project
  web_backend_service = google_compute_backend_service.default.name
  role                = "roles/iap.httpsResourceAccessor"
  member              = var.iap_access_principle
}

# Grant the Cloud Run Invoker role (roles/run.invoker) to the service agent that's used by IAP
resource "google_project_iam_member" "iap_invoker" {
  project = local.deployment_project
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_project_service_identity.default.email}"
}

# Grant the Cloud run service account access to create tokens for itself
resource "google_service_account_iam_member" "default" {
  count  = var.enable_multi_party_approval == true ? 1 : 0
  role   = "roles/iam.serviceAccountTokenCreator"
  member = "serviceAccount:${google_service_account.default.email}"

  service_account_id = google_service_account.default.name
}

resource "google_secret_manager_secret_iam_member" "default" {
  count   = var.enable_multi_party_approval == true ? 1 : 0
  project = local.deployment_project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.default.email}"

  secret_id = google_secret_manager_secret.default[0].id
}

# Grant the roles to allow changes at the requested hierarchy
resource "google_project_iam_member" "application_project_iam_admin" {
  count  = var.acting_project == "" ? 0 : 2
  member = "serviceAccount:${google_service_account.default.email}"
  role   = local.app_roles[count.index]

  project = var.acting_project
}

resource "google_folder_iam_member" "application_folder_iam_admin" {
  count  = var.acting_folder == "" ? 0 : 2
  role   = local.app_roles[count.index]
  member = "serviceAccount:${google_service_account.default.email}"

  folder = var.acting_folder
}

resource "google_organization_iam_member" "application_org_iam_admin" {
  count  = var.acting_organization == "" ? 0 : 2
  role   = local.app_roles[count.index]
  member = "serviceAccount:${google_service_account.default.email}"

  org_id = var.acting_organization
}




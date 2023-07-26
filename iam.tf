# who can access the application it might be better to also keep these alongside your organizations IAM
## Remove THIS
resource "google_iap_web_backend_service_iam_member" "iap_http_access" {
  project             = local.deployment_project
  web_backend_service = google_compute_backend_service.default.name
  role                = "roles/iap.httpsResourceAccessor"
  member              = var.iap_access_principle
}

# allows the IAP service account to invoke cloud run
resource "google_project_iam_member" "iap_invoker" {
  project = local.deployment_project
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_project_service_identity.default.email}"
}





# sets the application required roles at either the project, folder or organisation level.
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




resource "google_cloud_run_service" "default" {
  project  = local.deployment_project
  name     = var.application_name
  location = var.region

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }

  autogenerate_revision_name = true

  template {
    spec {
      containers {
        image = var.container_image
        env {
          name  = "RESOURCE_SCOPE"
          value = "${var.scope_type}/${local.scope_id}"
        }
        env {
          name  = "ACTIVATION_TIMEOUT"
          value = "60"
        }
        env {
          name  = "JUSTIFICATION_HINT"
          value = "Bug or case number"
        }
        env {
          name  = "JUSTIFICATION_PATTERN"
          value = ".*"
        }
        env {
          name  = "IAP_BACKEND_SERVICE_ID"
          value = google_compute_backend_service.default.generated_id
        }
      }
      service_account_name = google_service_account.default.email
    }
  }
}

# Service account attached to Cloud Run
resource "google_service_account" "default" {
  description = "JIT Cloud Run Attached Service Account"
  project     = local.deployment_project
  account_id  = "${var.application_name}-sa"
}


resource "google_cloud_run_service_iam_member" "default" {
  count   = var.allow_unauthenticated_invocations == true ? 1 : 0
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
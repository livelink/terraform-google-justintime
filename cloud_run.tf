# service account attached to Cloud Run Aplication
resource "google_service_account" "default" {
  description = "JIT Cloud Run Attached Service Account"
  project     = local.deployment_project
  account_id  = "${var.application_name}-sa"
}


# application resource when multi party approval is off.
resource "google_cloud_run_service" "no_approval" {
  count    = var.enable_multi_party_approval == false ? 1 : 0
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

# allowing unauthenticated users when multi party approval is off.
resource "google_cloud_run_service_iam_member" "no_approval" {
  count    = var.allow_unauthenticated_invocations == true && var.enable_multi_party_approval == true ? 1 : 0
  location = google_cloud_run_service.no_approval[0].location
  project  = google_cloud_run_service.no_approval[0].project
  service  = google_cloud_run_service.no_approval[0].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}




# application resource when multi party approval is on.
resource "google_cloud_run_service" "approval" {
  count    = var.enable_multi_party_approval == true ? 1 : 0
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
        env {
          name  = "SMTP_SENDER_ADDRESS"
          value = var.smtp_user_workspace_principle
        }
        env {
          name  = "SMTP_USERNAME"
          value = var.smtp_user_workspace_principle
        }
        env {
          name  = "SMTP_SECRET"
          value = google_secret_manager_secret.default[0].id
        }


      }
      service_account_name = google_service_account.default.email
    }
  }
}


# allowing unauthenticated users when multi party approval is on.
resource "google_cloud_run_service_iam_member" "approval" {
  count    = var.allow_unauthenticated_invocations == true && var.enable_multi_party_approval == false ? 1 : 0
  location = google_cloud_run_service.approval[0].location
  project  = google_cloud_run_service.approval[0].project
  service  = google_cloud_run_service.approval[0].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
resource "google_compute_global_address" "default" {
  project = local.deployment_project
  name    = var.application_name
}

resource "google_compute_managed_ssl_certificate" "default" {
  project = local.deployment_project
  name    = var.application_name
  managed {
    domains = [var.dns_name]
  }
}

resource "google_compute_backend_service" "default" {
  project = local.deployment_project
  name    = "${var.application_name}-backend"

  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30

  iap {
    oauth2_client_id     = google_iap_client.default.client_id
    oauth2_client_secret = google_iap_client.default.secret
  }

  backend {
    group = google_compute_region_network_endpoint_group.default.id
  }
}

resource "google_compute_url_map" "default" {
  project         = local.deployment_project
  name            = var.application_name
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_target_https_proxy" "default" {
  project = local.deployment_project
  name    = var.application_name
  url_map = google_compute_url_map.default.id

  ssl_certificates = [
    google_compute_managed_ssl_certificate.default.id
  ]
}

resource "google_compute_global_forwarding_rule" "default" {
  project    = local.deployment_project
  name       = var.application_name
  target     = google_compute_target_https_proxy.default.id
  port_range = "443"
  ip_address = google_compute_global_address.default.address
}

resource "google_compute_region_network_endpoint_group" "default" {
  project               = local.deployment_project
  name                  = var.application_name
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = var.application_name
  }
}
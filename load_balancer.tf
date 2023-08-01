# sets global address name
  resource "google_compute_global_address" "default" {
  project = local.deployment_project
  name    = var.application_name
}

# creates google managed ssl certificate for the provided domain.
resource "google_compute_managed_ssl_certificate" "default" {
  project = local.deployment_project
  name    = random_id.certificate.hex
  managed {
    domains = local.managed_domains
  }
  lifecycle {
    create_before_destroy = true
  }
}

# random id generated for ssl name
resource "random_id" "certificate" {
  byte_length = 4
  prefix      = "just-in-time-certificate-"
  keepers = {
    domains = join(",", local.managed_domains)
  }
}

# creates the load balancers backend service.
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

# creates a url map with a single route
resource "google_compute_url_map" "default" {
  project         = local.deployment_project
  name            = var.application_name
  default_service = google_compute_backend_service.default.id
}

# creates a target https proxy routing to the url map
resource "google_compute_target_https_proxy" "default" {
  project = local.deployment_project
  name    = var.application_name
  url_map = google_compute_url_map.default.id

  ssl_certificates = [
    google_compute_managed_ssl_certificate.default.id
  ]
}

# forwards traffic to the target https proxy
resource "google_compute_global_forwarding_rule" "default" {
  project    = local.deployment_project
  name       = var.application_name
  target     = google_compute_target_https_proxy.default.id
  port_range = "443"
  ip_address = google_compute_global_address.default.address
}

# configures the NEG https://cloud.google.com/load-balancing/docs/negs
resource "google_compute_region_network_endpoint_group" "default" {
  project               = local.deployment_project
  name                  = var.application_name
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = var.application_name
  }
}
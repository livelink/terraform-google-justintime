
# dynamically collects the service account attached to the iap
# https://registry.terraform.io/providers/hashicorp/google/4.74.0/docs/resources/project_service_identity
resource "google_project_service_identity" "default" {
  project  = local.deployment_project
  provider = google-beta
  service  = "iap.googleapis.com"
}

# Oauth for the IAP
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_brand.html
resource "google_iap_brand" "default" {
  project           = local.deployment_project
  support_email     = var.support_email
  application_title = var.application_name
}


# describes an iap owned client
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_client
resource "google_iap_client" "default" {
  display_name = "JIT Client"
  brand        = google_iap_brand.default.name
}
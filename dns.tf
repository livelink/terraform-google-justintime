resource "google_dns_managed_zone" "zone" {
  name        = "iamjustintime-livelinklabs-delegation"
  dns_name    = var.dns_name
  description = "Delegated zone for iamjustintime application"
}

resource "google_dns_record_set" "frontend" {
  name = google_dns_managed_zone.zone.dns_name
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.zone.name
  rrdatas = google_compute_global_address.default.address
}
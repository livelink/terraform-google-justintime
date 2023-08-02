output "external_ip_address" {
  value = google_compute_global_address.default.address
}

output "dns_name_servers" {
  value = google_dns_managed_zone.default.name_servers
}
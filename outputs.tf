output "load_balancer_ip" {
  description = "Global IPv4 address of the HTTP load balancer."
  value       = google_compute_global_address.web.address
}

output "website_url" {
  description = "URL of the deployed web tier."
  value       = "http://${google_compute_global_address.web.address}"
}

output "network_id" {
  description = "ID of the VPC network."
  value       = google_compute_network.main.id
}

output "subnetwork_id" {
  description = "ID of the web subnetwork."
  value       = google_compute_subnetwork.web.id
}

output "managed_instance_group" {
  description = "Self-link of the regional managed instance group."
  value       = google_compute_region_instance_group_manager.web.instance_group
}

output "instance_service_account" {
  description = "Email of the service account attached to web instances."
  value       = google_service_account.web.email
}


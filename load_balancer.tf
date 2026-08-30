resource "google_compute_global_address" "web" {
  name = "${var.name}-ipv4"
}

resource "google_compute_backend_service" "web" {
  name                  = "${var.name}-backend"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.web.id]

  backend {
    group           = google_compute_region_instance_group_manager.web.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

resource "google_compute_url_map" "web" {
  name            = "${var.name}-url-map"
  default_service = google_compute_backend_service.web.id
}

resource "google_compute_target_http_proxy" "web" {
  name    = "${var.name}-http-proxy"
  url_map = google_compute_url_map.web.id
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${var.name}-http"
  ip_address            = google_compute_global_address.web.id
  port_range            = "80"
  target                = google_compute_target_http_proxy.web.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}


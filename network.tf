resource "google_compute_network" "main" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [google_project_service.required]
}

resource "google_compute_subnetwork" "web" {
  name                     = "${var.name}-web-${var.region}"
  region                   = var.region
  network                  = google_compute_network.main.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true
}

resource "google_compute_router" "main" {
  name    = "${var.name}-router"
  region  = var.region
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "main" {
  name                               = "${var.name}-nat"
  region                             = var.region
  router                             = google_compute_router.main.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.web.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "health_checks" {
  name      = "${var.name}-allow-health-checks"
  network   = google_compute_network.main.name
  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]
  target_tags = [local.web_tag]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "iap_ssh" {
  count = var.enable_iap_ssh ? 1 : 0

  name          = "${var.name}-allow-iap-ssh"
  network       = google_compute_network.main.name
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["35.235.240.0/20"]
  target_tags   = [local.web_tag]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}


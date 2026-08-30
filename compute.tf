resource "google_compute_instance_template" "web" {
  name_prefix  = "${var.name}-web-"
  machine_type = var.machine_type
  tags         = [local.web_tag]
  labels       = local.labels

  disk {
    source_image = var.source_image
    auto_delete  = true
    boot         = true
    disk_type    = "pd-balanced"
    disk_size_gb = 10
  }

  network_interface {
    subnetwork = google_compute_subnetwork.web.id
  }

  service_account {
    email  = google_service_account.web.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    enable-oslogin         = "TRUE"
    block-project-ssh-keys = "TRUE"
  }

  metadata_startup_script = file("${path.module}/scripts/startup.sh")

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    google_compute_router_nat.main,
    google_project_iam_member.web_logging,
    google_project_iam_member.web_metrics,
  ]
}

resource "google_compute_health_check" "web" {
  name                = "${var.name}-http-health"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port         = 80
    request_path = "/healthz"
  }

  log_config {
    enable = true
  }
}

resource "google_compute_region_instance_group_manager" "web" {
  name               = "${var.name}-mig"
  region             = var.region
  base_instance_name = "${var.name}-web"
  target_size        = var.min_replicas

  distribution_policy_zones = var.zones

  version {
    name              = "primary"
    instance_template = google_compute_instance_template.web.id
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.web.id
    initial_delay_sec = 180
  }

  update_policy {
    type                         = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = length(var.zones)
    max_unavailable_fixed        = 0
    replacement_method           = "SUBSTITUTE"
    instance_redistribution_type = "PROACTIVE"
  }
}

resource "google_compute_region_autoscaler" "web" {
  name   = "${var.name}-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.web.id

  autoscaling_policy {
    min_replicas    = var.min_replicas
    max_replicas    = var.max_replicas
    cooldown_period = 90

    cpu_utilization {
      target = var.cpu_target
    }

    scale_in_control {
      max_scaled_in_replicas {
        percent = 50
      }
      time_window_sec = 300
    }
  }
}


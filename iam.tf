resource "google_service_account" "web" {
  account_id   = substr(replace("${var.name}-web", "_", "-"), 0, 30)
  display_name = "${var.name} web instance identity"
  description  = "Least-privilege identity used by the ${var.name} managed instance group."

  depends_on = [google_project_service.required]
}

resource "google_project_iam_member" "web_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.web.email}"
}

resource "google_project_iam_member" "web_metrics" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.web.email}"
}


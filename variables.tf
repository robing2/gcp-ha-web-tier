variable "project_id" {
  description = "GCP project ID in which to create resources."
  type        = string
}

variable "name" {
  description = "Prefix used for resource names."
  type        = string
  default     = "ha-web"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}[a-z0-9]$", var.name))
    error_message = "name must be 3-22 lowercase letters, numbers, or hyphens, starting with a letter and ending with a letter or number."
  }
}

variable "region" {
  description = "Region for the regional managed instance group and subnet."
  type        = string
  default     = "us-central1"
}

variable "zones" {
  description = "Zones used by the regional managed instance group. Use at least two for high availability."
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]

  validation {
    condition     = length(var.zones) >= 2 && alltrue([for zone in var.zones : startswith(zone, "${var.region}-")])
    error_message = "zones must contain at least two zones in var.region."
  }
}

variable "subnet_cidr" {
  description = "Primary IPv4 CIDR for the web subnet."
  type        = string
  default     = "10.10.0.0/24"
}

variable "machine_type" {
  description = "Compute Engine machine type for web instances."
  type        = string
  default     = "e2-micro"
}

variable "source_image" {
  description = "Boot disk image for web instances."
  type        = string
  default     = "projects/debian-cloud/global/images/family/debian-12"
}

variable "min_replicas" {
  description = "Minimum number of instances in the regional MIG."
  type        = number
  default     = 2

  validation {
    condition     = var.min_replicas >= 2
    error_message = "min_replicas must be at least 2 for high availability."
  }
}

variable "max_replicas" {
  description = "Maximum number of instances in the regional MIG."
  type        = number
  default     = 6

  validation {
    condition     = var.max_replicas >= var.min_replicas
    error_message = "max_replicas must be greater than or equal to min_replicas."
  }
}

variable "cpu_target" {
  description = "Average CPU utilization that triggers autoscaling."
  type        = number
  default     = 0.6

  validation {
    condition     = var.cpu_target > 0 && var.cpu_target <= 1
    error_message = "cpu_target must be greater than 0 and no greater than 1."
  }
}

variable "enable_iap_ssh" {
  description = "Allow SSH from Google's IAP TCP forwarding address range. IAM access is still required."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Additional labels to apply to supported resources."
  type        = map(string)
  default = {
    environment = "production"
    managed-by  = "terraform"
  }
}


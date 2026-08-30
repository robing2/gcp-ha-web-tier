locals {
  web_tag = "${var.name}-web"
  labels  = merge(var.labels, { application = var.name })
}


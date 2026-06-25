locals {
  prefix = "${var.project}-${var.environment}"

  common_tags = {
    project     = var.project
    environment = var.environment
    owner       = "formation"
    managed_by  = "terraform"
    cost_center = "cloud-training"
  }
}

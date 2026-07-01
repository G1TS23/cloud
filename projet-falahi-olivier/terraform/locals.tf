locals {
  prefix = "${var.project}-${var.environment}"

  common_tags = {
    application = var.project
    environment = var.environment
    owner       = "equipe-cloud"
    cost_center = "formation"
    criticality = "medium"
    review_date = "2026-12-31"
    managed_by  = "terraform"
  }
}

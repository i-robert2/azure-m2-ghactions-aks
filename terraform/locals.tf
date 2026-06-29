locals {
  base = "${var.project}-${var.environment}-${var.region_short}-${var.instance}"

  base_alphanum = lower(replace(local.base, "-", ""))
  acr_name      = substr("acr${local.base_alphanum}", 0, 24)
  kv_name       = substr("kv-${local.base}", 0, 24)
  pg_name       = "pg-${local.base}"

  tags = {
    project      = var.project
    environment  = var.environment
    managed_by   = "terraform"
    keep         = "false"
    keep_until   = var.keep_until
    owner        = var.owner
    cost_center  = "learning"
    created_date = timestamp()
  }
}

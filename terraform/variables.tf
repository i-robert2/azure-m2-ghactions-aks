variable "project" { type = string }
variable "environment" { type = string }
variable "region" {
  type    = string
  default = "swedencentral"
}
variable "region_short" {
  type    = string
  default = "sdc"
}
variable "instance" {
  type    = string
  default = "001"
}
variable "owner" { type = string }
variable "keep_until" { type = string }

variable "pg_admin_login" {
  type    = string
  default = "pgadmin"
}

# Postgres availability zone. Burstable SKU zone support varies by region/time;
# override to "2" or "3" if "1" is rejected.
variable "pg_zone" {
  type    = string
  default = "1"
}

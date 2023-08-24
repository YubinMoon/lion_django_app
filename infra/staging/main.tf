terraform {
  required_providers {
    ncloud = {
      source = "NaverCloudPlatform/ncloud"
    }
  }
  required_version = ">= 0.13"
}

// Configure the ncloud provider
provider "ncloud" {
  access_key  = var.NCP_ACCESS_KEY
  secret_key  = var.NCP_SECRET_KEY
  region      = "KR"
  site        = "PUBLIC"
  support_vpc = true
}

module "servers" {
  source = "../modules/server"

  postgres_db       = var.postgres_db
  postgres_user     = var.postgres_user
  postgres_password = var.postgres_password
  ncr_registry      = var.ncr_registry
  django_secret_key = var.django_secret_key
  NCP_ACCESS_KEY    = var.NCP_ACCESS_KEY
  NCP_SECRET_KEY    = var.NCP_SECRET_KEY
  password          = var.password
  mode              = "staging"
  env               = "staging"
}

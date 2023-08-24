terraform {
  required_providers {
    ncloud = {
      source = "NaverCloudPlatform/ncloud"
    }
  }
  required_version = ">= 0.13"
}

provider "ncloud" {
  region      = "KR"
  support_vpc = true
}

locals {
  env = "prod"
}

module "vpc" {
  source = "../modules/network"

  env = local.env
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
  django_mode       = "prod"
  env               = local.env
  vpc_no            = module.vpc.vpc_no
}

module "loadbalancer" {
  source = "../modules/loadbalancer"

  env            = local.env
  vpc_no         = module.vpc.vpc_no
  server_id_list = module.servers.be_server_list
}

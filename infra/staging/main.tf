terraform {
  # backend "pg" {
  #   conn_str = "postgres://postgres:terry@223.130.133.132/postgres"
  # }

  backend "pg" {}
  required_providers {
    ncloud = {
      source = "NaverCloudPlatform/ncloud"
    }
  }
  required_version = ">= 0.13"
}

provider "ncloud" {
  access_key  = var.NCP_ACCESS_KEY
  secret_key  = var.NCP_SECRET_KEY
  region      = "KR"
  site        = "PUBLIC"
  support_vpc = true
}

locals {
  env = "stage"
}

module "vpc" {
  source = "../modules/network"

  NCP_ACCESS_KEY = var.NCP_ACCESS_KEY
  NCP_SECRET_KEY = var.NCP_SECRET_KEY
  env            = local.env
}

module "db_server" {
  source = "../modules/server"

  NCP_ACCESS_KEY    = var.NCP_ACCESS_KEY
  NCP_SECRET_KEY    = var.NCP_SECRET_KEY
  password          = var.password
  postgres_db       = var.postgres_db
  postgres_user     = var.postgres_user
  postgres_password = var.postgres_password
  ncr_registry      = var.ncr_registry
  django_secret_key = var.django_secret_key
  django_mode       = "staging"
  env               = local.env
  name              = "db"
  vpc_no            = module.vpc.vpc_no
  subnet_no         = module.vpc.subnet_no
  port              = "5432"
}
module "be_server" {
  source = "../modules/server"

  NCP_ACCESS_KEY    = var.NCP_ACCESS_KEY
  NCP_SECRET_KEY    = var.NCP_SECRET_KEY
  password          = var.password
  postgres_db       = var.postgres_db
  postgres_user     = var.postgres_user
  postgres_password = var.postgres_password
  ncr_registry      = var.ncr_registry
  django_secret_key = var.django_secret_key
  django_mode       = "staging"
  env               = local.env
  name              = "be"
  vpc_no            = module.vpc.vpc_no
  subnet_no         = module.vpc.subnet_no
  port              = "8000"
  db_host           = module.db_server.public_ip
}

module "loadbalancer" {
  source = "../modules/loadbalancer"

  NCP_ACCESS_KEY = var.NCP_ACCESS_KEY
  NCP_SECRET_KEY = var.NCP_SECRET_KEY
  env            = local.env
  vpc_no         = module.vpc.vpc_no
  server_id_list = module.be_server.server_id
}

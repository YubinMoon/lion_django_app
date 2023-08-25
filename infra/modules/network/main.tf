terraform {
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

resource "ncloud_vpc" "main" {
  name            = "${var.env}-lion-prod-vpc"
  ipv4_cidr_block = "192.168.0.0/16"
}

resource "ncloud_subnet" "server" {
  name           = "${var.env}-lion-subnet"
  vpc_no         = ncloud_vpc.main.vpc_no
  subnet         = "192.168.21.0/24"
  zone           = "KR-2"
  network_acl_no = ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PUBLIC"
  usage_type     = "GEN"
}

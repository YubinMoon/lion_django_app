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
  support_vpc = true
}


resource "ncloud_vpc" "main" {
  name            = "${var.env}-lion-prod-vpc"
  ipv4_cidr_block = "192.168.0.0/16"
}

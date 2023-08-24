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

resource "ncloud_vpc" "main" {
  name            = "${var.env}-lion-prod-vpc"
  ipv4_cidr_block = "192.168.0.0/16"
}

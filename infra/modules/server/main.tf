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

data "ncloud_vpc" "main" {
  id = var.vpc_no
}

data "ncloud_subnet" "main" {
  id = var.subnet_no
}

resource "ncloud_login_key" "main" {
  key_name = "${var.env}-key"
}

resource "ncloud_init_script" "init" {
  name = "${var.env}-${var.name}-init-script"
  content = templatefile("${path.module}/init_script.sh", {
    password          = var.password
    postgres_db       = var.postgres_db
    postgres_user     = var.postgres_user
    postgres_password = var.postgres_password
    postgres_port     = var.postgres_port
    ncr_registry      = var.ncr_registry
    docker_user       = var.NCP_ACCESS_KEY
    docker_password   = var.NCP_SECRET_KEY
    django_secret_key = var.django_secret_key
    django_mode       = var.django_mode
    db_host           = var.db_host
  })
}

resource "ncloud_server" "server" {
  name                      = "${var.env}-${var.name}-server"
  subnet_no                 = data.ncloud_subnet.main.subnet_no
  server_image_product_code = var.server_image_product_code
  server_product_code       = data.ncloud_server_product.product.id
  login_key_name            = ncloud_login_key.main.id
  init_script_no            = ncloud_init_script.init.id
  network_interface {
    network_interface_no = ncloud_network_interface.prod_be.id
    order                = 0
  }
}

data "ncloud_server_product" "product" {
  server_image_product_code = var.server_image_product_code

  filter {
    name   = "product_code"
    values = ["SSD"]
    regex  = true
  }
  filter {
    name   = "cpu_count"
    values = ["2"]
  }
  filter {
    name   = "product_type"
    values = ["HICPU"]
  }
}

resource "ncloud_access_control_group" "default" {
  name   = "${var.env}-${var.name}-acg"
  vpc_no = data.ncloud_vpc.main.vpc_no
}

resource "ncloud_access_control_group_rule" "rule" {
  access_control_group_no = ncloud_access_control_group.default.id

  inbound {
    protocol   = "TCP"
    ip_block   = "0.0.0.0/0"
    port_range = var.port
  }
}

resource "ncloud_network_interface" "prod_be" {
  name                  = "${var.env}-${var.name}-interface"
  subnet_no             = data.ncloud_subnet.main.subnet_no
  access_control_groups = [data.ncloud_vpc.main.default_access_control_group_no, ncloud_access_control_group.default.id]
}

resource "ncloud_public_ip" "public_be" {
  server_instance_no = ncloud_server.server.id
}

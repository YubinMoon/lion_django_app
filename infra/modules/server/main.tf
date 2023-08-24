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

data "ncloud_vpc" "main" {
  id = var.vpc_no
}

resource "ncloud_login_key" "main" {
  key_name = "${var.env}-prod-key"
}

resource "ncloud_subnet" "main" {
  name           = "${var.env}-lion-prod-subnet"
  vpc_no         = data.ncloud_vpc.main.vpc_no
  subnet         = "192.168.21.0/24"
  zone           = "KR-2"
  network_acl_no = data.ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PUBLIC"
  usage_type     = "GEN"
}

resource "ncloud_init_script" "prod_be" {
  name = "${var.env}-be-init-script"
  content = templatefile("${path.module}/be_init_script.sh", {
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
    db_host           = ncloud_public_ip.public_db.public_ip
  })
}

resource "ncloud_init_script" "prod_db" {
  name = "${var.env}-db-init-script"
  content = templatefile("${path.module}/db_init_script.sh", {
    password          = var.password
    postgres_db       = var.postgres_db
    postgres_user     = var.postgres_user
    postgres_password = var.postgres_password
    postgres_port     = var.postgres_port
  })
}

resource "ncloud_server" "prod_be" {
  name                      = "${var.env}-be-server"
  subnet_no                 = ncloud_subnet.main.id
  server_image_product_code = var.server_image_product_code
  server_product_code       = data.ncloud_server_product.product.id
  login_key_name            = ncloud_login_key.main.key_name
  init_script_no            = ncloud_init_script.prod_be.id
  network_interface {
    network_interface_no = ncloud_network_interface.prod_be.id
    order                = 0
  }
}

resource "ncloud_server" "prod_db" {
  name                      = "${var.env}-db-server"
  subnet_no                 = ncloud_subnet.main.id
  server_image_product_code = var.server_image_product_code
  server_product_code       = data.ncloud_server_product.product.id
  login_key_name            = ncloud_login_key.main.key_name
  init_script_no            = ncloud_init_script.prod_db.id
  network_interface {
    network_interface_no = ncloud_network_interface.prod_db.id
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

resource "ncloud_access_control_group" "django" {
  name   = "${var.env}-django-acg"
  vpc_no = data.ncloud_vpc.main.vpc_no
}

resource "ncloud_access_control_group_rule" "django-rule" {
  access_control_group_no = ncloud_access_control_group.django.id

  inbound {
    protocol   = "TCP"
    ip_block   = "0.0.0.0/0"
    port_range = "8000"
  }
}

resource "ncloud_access_control_group" "postgres" {
  name   = "${var.env}-postgres-acg"
  vpc_no = data.ncloud_vpc.main.vpc_no
}

resource "ncloud_access_control_group_rule" "postgres-rule" {
  access_control_group_no = ncloud_access_control_group.postgres.id

  inbound {
    protocol   = "TCP"
    ip_block   = "0.0.0.0/0"
    port_range = "5432"
  }
}

resource "ncloud_network_interface" "prod_be" {
  name                  = "${var.env}-be-interface"
  subnet_no             = ncloud_subnet.main.id
  private_ip            = "192.168.21.6"
  access_control_groups = [data.ncloud_vpc.main.default_access_control_group_no, ncloud_access_control_group.django.id]
}

resource "ncloud_network_interface" "prod_db" {
  name                  = "${var.env}-db-interface"
  subnet_no             = ncloud_subnet.main.id
  private_ip            = "192.168.21.7"
  access_control_groups = [data.ncloud_vpc.main.default_access_control_group_no, ncloud_access_control_group.postgres.id]
}


resource "ncloud_public_ip" "public_be" {
  server_instance_no = ncloud_server.prod_be.id
}

resource "ncloud_public_ip" "public_db" {
  server_instance_no = ncloud_server.prod_db.id
}

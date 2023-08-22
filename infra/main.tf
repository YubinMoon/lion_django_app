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
  site        = "PUBLIC"
  support_vpc = true
}

resource "ncloud_login_key" "loginkey" {
  key_name = "lion-key"
}

resource "ncloud_vpc" "lion" {
  ipv4_cidr_block = "10.1.0.0/16"
  name            = "lion-vpc"
}

resource "ncloud_subnet" "main" {
  vpc_no         = ncloud_vpc.lion.vpc_no
  subnet         = cidrsubnet(ncloud_vpc.lion.ipv4_cidr_block, 8, 1)
  zone           = "KR-2"
  network_acl_no = ncloud_vpc.lion.default_network_acl_no
  subnet_type    = "PUBLIC"
  usage_type     = "GEN"
  name           = "lion-subnet"
}

resource "ncloud_init_script" "main" {
  name    = "init-main"
  content = <<EOF
#!/bin/bash

USERNAME="asdf"
PASSWORD="asdf"

# useradd
useradd -m -s /bin/bash $USERNAME
# password
echo "$USERNAME:$PASSWORD" | chpasswd
# sudo with no password
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
# update
apt-get update
# set docker
apt-get install -y docker.io
usermod -aG docker $USERNAME
EOF
}

data "ncloud_server_products" "small" {
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"

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
    name   = "memory_size"
    values = ["4GB"]
  }

  filter {
    name   = "base_block_storage_size"
    values = ["50GB"]
  }

  filter {
    name   = "product_type"
    values = ["HICPU"]
  }
}

resource "ncloud_access_control_group" "db" {
  name        = "db-acg"
  description = "description"
  vpc_no      = ncloud_vpc.lion.id
}

resource "ncloud_access_control_group_rule" "acg-rule" {
  access_control_group_no = ncloud_access_control_group.db.id

  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "5432"
    description = "accept postgresql port"
  }
}

resource "ncloud_server" "be" {
  name                      = "staging"
  subnet_no                 = ncloud_subnet.main.id
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  server_product_code       = data.ncloud_server_products.small.server_products[0].id
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no            = ncloud_init_script.main.id
}

resource "ncloud_public_ip" "be" {
  server_instance_no = ncloud_server.be.id
}

resource "ncloud_network_interface" "db" {
  name                  = "my-interface"
  description           = "acg test"
  subnet_no             = ncloud_subnet.main.id
  private_ip            = "10.1.1.6"
  access_control_groups = [ncloud_vpc.lion.default_access_control_group_no, ncloud_access_control_group.db.id]
}

resource "ncloud_server" "db" {
  name                      = "db-server"
  subnet_no                 = ncloud_subnet.main.id
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  server_product_code       = data.ncloud_server_products.small.server_products[0].id
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no            = ncloud_init_script.main.id
  network_interface {
    network_interface_no = ncloud_network_interface.db.id
    order                = 0
  }
}

resource "ncloud_public_ip" "db" {
  server_instance_no = ncloud_server.db.id
}

output "products" {
  value = {
    for product in data.ncloud_server_products.small.server_products :
    product.id => product.product_name
  }
}

output "tutorial_ip" {
  value = ncloud_public_ip.be.public_ip
}

output "db_ip" {
  value = ncloud_public_ip.db.public_ip
}

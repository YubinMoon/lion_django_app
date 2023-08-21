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
  key_name = "lion-tf-key"
}

resource "ncloud_vpc" "test" {
  ipv4_cidr_block = "10.1.0.0/16"
  name            = "lion-tf"
}

resource "ncloud_subnet" "test" {
  vpc_no         = ncloud_vpc.test.vpc_no
  subnet         = cidrsubnet(ncloud_vpc.test.ipv4_cidr_block, 8, 1)
  zone           = "KR-2"
  network_acl_no = ncloud_vpc.test.default_network_acl_no
  subnet_type    = "PUBLIC"
  usage_type     = "GEN"
  name           = "lion-tf-sub"
}

resource "ncloud_init_script" "init_script" {
  name    = "init-script"
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

data "ncloud_server_products" "products" {
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

resource "ncloud_server" "tutorial" {
  name                      = "my-tf-server"
  subnet_no                 = ncloud_subnet.test.id
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  server_product_code       = data.ncloud_server_products.products.server_products[0].id
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no            = ncloud_init_script.init_script.id
}

resource "ncloud_public_ip" "tutorial_ip" {
  server_instance_no = ncloud_server.tutorial.id
}

resource "ncloud_server" "db" {
  name                      = "my-tf-db"
  subnet_no                 = ncloud_subnet.test.id
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  server_product_code       = data.ncloud_server_products.products.server_products[0].id
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no            = ncloud_init_script.init_script.id
}

resource "ncloud_public_ip" "db_ip" {
  server_instance_no = ncloud_server.db.id
}

output "products" {
  value = {
    for product in data.ncloud_server_products.products.server_products :
    product.id => product.product_name
  }
}

output "tutorial_ip" {
  value = ncloud_public_ip.tutorial_ip.public_ip
}

output "db_ip" {
  value = ncloud_public_ip.tutorial_ip.public_ip
}

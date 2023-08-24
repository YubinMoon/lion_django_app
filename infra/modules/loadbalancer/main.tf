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

resource "ncloud_subnet" "lb" {
  name           = "${var.env}-lb-subnet"
  vpc_no         = data.ncloud_vpc.main.vpc_no
  subnet         = cidrsubnet(data.ncloud_vpc.main.ipv4_cidr_block, 8, 2)
  zone           = "KR-2"
  network_acl_no = data.ncloud_vpc.main.default_network_acl_no
  subnet_type    = "PRIVATE"
  usage_type     = "LOADB"
}


resource "ncloud_lb_target_group" "lion_target" {
  name        = "${var.env}-target-group"
  vpc_no      = data.ncloud_vpc.main.vpc_no
  protocol    = "PROXY_TCP"
  target_type = "VSVR"
  port        = 8000
  description = "lion django ${var.env} target"
  health_check {
    protocol       = "TCP"
    http_method    = "GET"
    port           = 8000
    cycle          = 30
    up_threshold   = 2
    down_threshold = 2
  }
}

resource "ncloud_lb_target_group_attachment" "lion_target_server" {
  target_group_no = ncloud_lb_target_group.lion_target.target_group_no
  target_no_list  = var.server_id_list
}

resource "ncloud_lb" "lion_lb" {
  name           = "${var.env}-lb"
  network_type   = "PUBLIC"
  type           = "NETWORK_PROXY"
  subnet_no_list = [ncloud_subnet.lb.subnet_no]
}

resource "ncloud_lb_listener" "lion_lb_listener" {
  load_balancer_no = ncloud_lb.lion_lb.load_balancer_no
  protocol         = "TCP"
  port             = 80
  target_group_no  = ncloud_lb_target_group.lion_target.target_group_no
}

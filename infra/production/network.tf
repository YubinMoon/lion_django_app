# resource "ncloud_vpc" "main" {
#   name            = "lion-prod-vpc"
#   ipv4_cidr_block = "192.168.0.0/16"
# }

# resource "ncloud_subnet" "main" {
#   name           = "lion-prod-subnet"
#   vpc_no         = ncloud_vpc.main.id
#   subnet         = "192.168.21.0/24"
#   zone           = "KR-2"
#   network_acl_no = ncloud_vpc.main.default_network_acl_no
#   subnet_type    = "PUBLIC"
#   usage_type     = "GEN"
# }

# resource "ncloud_subnet" "lb" {
#   name           = "lion-lb-subnet"
#   vpc_no         = ncloud_vpc.main.id
#   subnet         = "192.168.10.0/24"
#   zone           = "KR-2"
#   network_acl_no = ncloud_vpc.main.default_network_acl_no
#   subnet_type    = "PRIVATE"
#   usage_type     = "LOADB"
# }

# resource "ncloud_access_control_group" "django" {
#   name   = "prod-django-acg"
#   vpc_no = ncloud_vpc.main.id
# }

# resource "ncloud_access_control_group_rule" "django-rule" {
#   access_control_group_no = ncloud_access_control_group.django.id

#   inbound {
#     protocol   = "TCP"
#     ip_block   = "0.0.0.0/0"
#     port_range = "8000"
#   }
# }

# resource "ncloud_access_control_group" "postgres" {
#   name   = "prod-postgres-acg"
#   vpc_no = ncloud_vpc.main.id
# }

# resource "ncloud_access_control_group_rule" "postgres-rule" {
#   access_control_group_no = ncloud_access_control_group.postgres.id

#   inbound {
#     protocol   = "TCP"
#     ip_block   = "0.0.0.0/0"
#     port_range = "5432"
#   }
# }

# resource "ncloud_network_interface" "prod_be" {
#   name                  = "prod-be-interface"
#   subnet_no             = ncloud_subnet.main.id
#   private_ip            = "192.168.21.6"
#   access_control_groups = [ncloud_vpc.main.default_access_control_group_no, ncloud_access_control_group.django.id]
# }

# resource "ncloud_network_interface" "prod_db" {
#   name                  = "prod-db-interface"
#   subnet_no             = ncloud_subnet.main.id
#   private_ip            = "192.168.21.7"
#   access_control_groups = [ncloud_vpc.main.default_access_control_group_no, ncloud_access_control_group.postgres.id]
# }

# resource "ncloud_public_ip" "public_be" {
#   server_instance_no = ncloud_server.prod_be.id
# }

# resource "ncloud_public_ip" "public_db" {
#   server_instance_no = ncloud_server.prod_db.id
# }

# resource "ncloud_vpc" "lion" {
#   ipv4_cidr_block = "10.1.0.0/16"
#   name            = "lion-vpc"
# }

# resource "ncloud_subnet" "main" {
#   vpc_no         = ncloud_vpc.lion.vpc_no
#   subnet         = cidrsubnet(ncloud_vpc.lion.ipv4_cidr_block, 8, 1)
#   zone           = "KR-2"
#   network_acl_no = ncloud_vpc.lion.default_network_acl_no
#   subnet_type    = "PUBLIC"
#   usage_type     = "GEN"
#   name           = "lion-subnet"
# }

# resource "ncloud_subnet" "be_lb" {
#   vpc_no         = ncloud_vpc.lion.vpc_no
#   subnet         = cidrsubnet(ncloud_vpc.lion.ipv4_cidr_block, 8, 2)
#   zone           = "KR-2"
#   network_acl_no = ncloud_vpc.lion.default_network_acl_no
#   subnet_type    = "PRIVATE"
#   usage_type     = "LOADB"
#   name           = "lion-be-lb"
# }

# resource "ncloud_public_ip" "be" {
#   server_instance_no = ncloud_server.be.id
# }

# resource "ncloud_public_ip" "db" {
#   server_instance_no = ncloud_server.db.id
# }

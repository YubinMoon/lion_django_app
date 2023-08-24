# data "ncloud_server_products" "small" {
#   server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"

#   filter {
#     name   = "product_code"
#     values = ["SSD"]
#     regex  = true
#   }

#   filter {
#     name   = "cpu_count"
#     values = ["2"]
#   }

#   filter {
#     name   = "memory_size"
#     values = ["4GB"]
#   }

#   filter {
#     name   = "base_block_storage_size"
#     values = ["50GB"]
#   }

#   filter {
#     name   = "product_type"
#     values = ["HICPU"]
#   }
# }

# resource "ncloud_init_script" "be" {
#   name = "set-be-tf"
#   content = templatefile("${path.module}/main_init_script.sh", {
#     password          = var.password
#     db_host           = ncloud_public_ip.db.public_ip
#     postgres_db       = var.postgres_db
#     postgres_user     = var.postgres_user
#     postgres_password = var.postgres_password
#     docker_user       = var.NCP_ACCESS_KEY
#     docker_password   = var.NCP_SECRET_KEY
#     django_secret_key = var.django_secret_key
#   })
# }

# resource "ncloud_access_control_group" "be" {
#   name   = "django-acg"
#   vpc_no = ncloud_vpc.lion.id
# }

# resource "ncloud_access_control_group_rule" "django-rule" {
#   access_control_group_no = ncloud_access_control_group.be.id

#   inbound {
#     protocol    = "TCP"
#     ip_block    = "0.0.0.0/0"
#     port_range  = "8000"
#     description = "django access port"
#   }
# }

# resource "ncloud_network_interface" "be" {
#   name                  = "django-interface"
#   description           = "acg test"
#   subnet_no             = ncloud_subnet.main.id
#   private_ip            = "10.1.1.7"
#   access_control_groups = [ncloud_vpc.lion.default_access_control_group_no, ncloud_access_control_group.be.id]
# }

# resource "ncloud_server" "be" {
#   name                      = "staging"
#   subnet_no                 = ncloud_subnet.main.id
#   server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
#   server_product_code       = data.ncloud_server_products.small.server_products[0].id
#   login_key_name            = ncloud_login_key.loginkey.key_name
#   init_script_no            = ncloud_init_script.be.id
#   network_interface {
#     network_interface_no = ncloud_network_interface.be.id
#     order                = 0
#   }
# }

# resource "ncloud_init_script" "db" {
#   name = "set-db-tf"
#   content = templatefile("${path.module}/main_init_script.sh", {
#     password          = var.password
#     db_host           = ""
#     postgres_db       = var.postgres_db
#     postgres_user     = var.postgres_user
#     postgres_password = var.postgres_password
#     docker_user       = var.NCP_ACCESS_KEY
#     docker_password   = var.NCP_SECRET_KEY
#     django_secret_key = var.django_secret_key
#   })
# }

# resource "ncloud_access_control_group" "db" {
#   name   = "db-acg"
#   vpc_no = ncloud_vpc.lion.id
# }

# resource "ncloud_access_control_group_rule" "db-rule" {
#   access_control_group_no = ncloud_access_control_group.db.id

#   inbound {
#     protocol    = "TCP"
#     ip_block    = "0.0.0.0/0"
#     port_range  = "5432"
#     description = "accept postgresql port"
#   }
# }

# resource "ncloud_network_interface" "db" {
#   name                  = "db-interface"
#   description           = "acg test"
#   subnet_no             = ncloud_subnet.main.id
#   private_ip            = "10.1.1.6"
#   access_control_groups = [ncloud_vpc.lion.default_access_control_group_no, ncloud_access_control_group.db.id]
# }

# resource "ncloud_server" "db" {
#   name                      = "db-server"
#   subnet_no                 = ncloud_subnet.main.id
#   server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
#   server_product_code       = data.ncloud_server_products.small.server_products[0].id
#   login_key_name            = ncloud_login_key.loginkey.key_name
#   init_script_no            = ncloud_init_script.db.id
#   network_interface {
#     network_interface_no = ncloud_network_interface.db.id
#     order                = 0
#   }
# }

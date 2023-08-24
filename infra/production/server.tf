# resource "ncloud_init_script" "prod_be" {
#   name = "prod-be-init-script"
#   content = templatefile("${path.module}/be_init_script.sh", {
#     password          = var.password
#     postgres_db       = var.postgres_db
#     postgres_user     = var.postgres_user
#     postgres_password = var.postgres_password
#     postgres_port     = var.postgres_port
#     ncr_registry      = var.ncr_registry
#     docker_user       = var.NCP_ACCESS_KEY
#     docker_password   = var.NCP_SECRET_KEY
#     django_secret_key = var.django_secret_key
#     db_host           = ncloud_public_ip.public_db.public_ip
#   })
# }

# resource "ncloud_init_script" "prod_db" {
#   name = "prod-db-init-script"
#   content = templatefile("${path.module}/db_init_script.sh", {
#     password          = var.password
#     postgres_db       = var.postgres_db
#     postgres_user     = var.postgres_user
#     postgres_password = var.postgres_password
#     postgres_port     = var.postgres_port
#   })
# }

# resource "ncloud_server" "prod_be" {
#   name                      = "prod-be-server"
#   subnet_no                 = ncloud_subnet.main.id
#   server_image_product_code = var.server_image_product_code
#   server_product_code       = data.ncloud_server_product.product.id
#   login_key_name            = ncloud_login_key.main.key_name
#   init_script_no            = ncloud_init_script.prod_be.id
#   network_interface {
#     network_interface_no = ncloud_network_interface.prod_be.id
#     order                = 0
#   }
# }

# resource "ncloud_server" "prod_db" {
#   name                      = "prod-db-server"
#   subnet_no                 = ncloud_subnet.main.id
#   server_image_product_code = var.server_image_product_code
#   server_product_code       = data.ncloud_server_product.product.id
#   login_key_name            = ncloud_login_key.main.key_name
#   init_script_no            = ncloud_init_script.prod_db.id
#   network_interface {
#     network_interface_no = ncloud_network_interface.prod_db.id
#     order                = 0
#   }
# }

# data "ncloud_server_product" "product" {
#   server_image_product_code = var.server_image_product_code

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
#     name   = "product_type"
#     values = ["HICPU"]
#   }
# }

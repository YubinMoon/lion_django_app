# output "products" {
#   value = {
#     for product in data.ncloud_server_products.small.server_products :
#     product.id => product.product_name
#   }
# }

# output "tutorial_ip" {
#   value = ncloud_public_ip.be.public_ip
# }

# output "db_ip" {
#   value = ncloud_public_ip.db.public_ip
# }

# output "loadbalance" {
#   value = ncloud_lb.lion_lb.domain
# }

output "be_public_ip" {
  value = module.servers.be_public_ip
}

output "db_public_ip" {
  value = module.servers.db_public_ip
}

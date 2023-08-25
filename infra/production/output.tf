# output "be_ip" {
#   value = ncloud_public_ip.public_be.public_ip
# }

# output "db_ip" {
#   value = ncloud_public_ip.public_db.public_ip
# }

# output "lb_url" {
#   value = ncloud_lb.prod_lb.domain
# }

output "be_public_ip" {
  value = module.be_server.public_ip
}

output "db_public_ip" {
  value = module.db_server.public_ip
}

output "domain" {
  value = module.loadbalancer.domain
}

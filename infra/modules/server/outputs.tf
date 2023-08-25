output "public_ip" {
  value = ncloud_public_ip.public_be.public_ip
}

output "server_id" {
  value = [ncloud_server.server.id]
}

output "be_public_ip" {
  value = ncloud_public_ip.public_be.public_ip
}

output "db_public_ip" {
  value = ncloud_public_ip.public_db.public_ip
}

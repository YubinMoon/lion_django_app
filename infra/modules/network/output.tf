output "vpc_no" {
  value = ncloud_vpc.main.id
}

output "subnet_no" {
  value = ncloud_subnet.server.subnet_no
}

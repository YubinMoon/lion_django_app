variable "vpc_no" {
  type = string
}

variable "env" {
  type = string
}

variable "server_id_list" {
  type = list(string)
}

variable "NCP_ACCESS_KEY" {
  type = string
}

variable "NCP_SECRET_KEY" {
  type      = string
  sensitive = true
}

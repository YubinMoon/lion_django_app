variable "env" {
  type = string
}

variable "NCP_ACCESS_KEY" {
  type = string
}

variable "NCP_SECRET_KEY" {
  type      = string
  sensitive = true
}

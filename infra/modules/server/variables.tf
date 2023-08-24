variable "NCP_ACCESS_KEY" {
  type      = string
  sensitive = true
}

variable "NCP_SECRET_KEY" {
  type      = string
  sensitive = true
}

variable "password" {
  type      = string
  sensitive = true
}

variable "server_image_product_code" {
  type    = string
  default = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
}

variable "postgres_db" {
  type = string
}

variable "postgres_user" {
  type = string
}

variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "postgres_port" {
  type    = string
  default = "5432"
}

variable "ncr_registry" {
  type = string
}

variable "django_secret_key" {
  type      = string
  sensitive = true
}

variable "mode" {
  type = string
}

variable "env" {
  type = string
}

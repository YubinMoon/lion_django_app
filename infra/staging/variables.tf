variable "NCP_ACCESS_KEY" {
  type = string
}

variable "NCP_SECRET_KEY" {
  type      = string
  sensitive = true
}

variable "password" {
  type      = string
  sensitive = true
}
variable "postgres_db" {
  type      = string
  sensitive = true
}
variable "postgres_user" {
  type      = string
  sensitive = true
}
variable "postgres_password" {
  type      = string
  sensitive = true
}
variable "docker_user" {
  type      = string
  sensitive = true
}
variable "docker_password" {
  type      = string
  sensitive = true
}

variable "ncr_registry" {
  type = string
}

variable "django_secret_key" {
  type      = string
  sensitive = true
}

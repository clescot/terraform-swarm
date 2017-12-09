variable "scaleway_organization" {
  description = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
variable "scaleway_token" {
  description = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
variable "scaleway_region" {
  description = "scaleway datacenter 'par1' for paris(France) or 'ams1' fr Amsterdam (Nederlands)"
  default="par1"
}
variable "scaleway_type" {
  description = "type of server"
  default="C2S"
}
variable "cloudflare_email" {
  description = "your email scaleway account identifier"
}
variable "cloudflare_token" {
  description = ""
}
variable "cloudflare_domain" {
  description = "your DNS domain managed by cloudflare"
}
variable "ubuntu_x86_64_image" {
  description = "your custom image ID"
}

variable "ssh_port" {
  description = "ssh port to connect"
}

variable "ssh_user" {
  description = "ssh user"
}

# variable "ssh_group" {
#   description = "ssh group"
# }



variable "bastion" {
    type = object({
        name         = string
        server_type  = string
        private_ip   = string
    })
}


variable "private_ip_range" {
  type=string
  default = "10.0.0.0/16"
}

variable "network_name" {
  type=string
  default = "default"
}

variable "private_network_zone" {
  type=string
  default = "eu-central"
}

variable "hcloud_location" {
  type=string
  default = "nbg1"
}


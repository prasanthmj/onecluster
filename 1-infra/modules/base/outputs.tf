output "bastion_ip"{
  value = hcloud_server.bastion.ipv4_address
  description = "Bastion Server IP"
}
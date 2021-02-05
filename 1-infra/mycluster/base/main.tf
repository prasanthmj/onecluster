
terraform {
  required_version = ">= 0.13"
}

provider "hcloud" {
}

module "base" {
  source = "../../modules/base"
  
  bastion ={
    name = "bastion"
    server_type = "cx31"
    private_ip   = "10.0.0.2"    
  }
  network_name="mycluster-main"
}

output "bastion_ip"{
  value = module.base.bastion_ip
  description = "Bastion Server IP"
}
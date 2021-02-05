terraform {
  required_version = ">= 0.13"
}

provider "hcloud" {
}

module "cluster" {
    source = "../../modules/hcloud"
    
    cluster_name = "staging"
    network_name = "mycluster-main"

    nodes = {
        1 = {
            name = "node4"
            server_type = "cx31"
            private_ip   = "10.0.0.15"
        }
        
        2 = {
            name = "node5"
            server_type = "cx31"
            private_ip   = "10.0.0.16"
        }
        
        3 = {
            name = "node6"
            server_type = "cx31"
            private_ip   = "10.0.0.17"
        }
    }

    load_balancer = {
        type="lb11"
        private_ip="10.0.0.13"
    }

    hcloud_location = "nbg1"
}

output "nodes" {
  value = module.cluster.nodes
  description = "Node Details"
}
output "load_balancer"{
  value = module.cluster.load_balancer
  description = "LoadBalancer IP"
}
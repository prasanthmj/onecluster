terraform {
  required_version = ">= 0.13"
}

provider "hcloud" {
}

module "cluster" {
    source = "../../modules/hcloud"
    
    cluster_name = "prod"
    network_name = "mycluster-main"

    nodes = {
        1 = {
            name = "node1"
            server_type = "cx21"
            private_ip   = "10.0.0.5"
        }
        
        2 = {
            name = "node2"
            server_type = "cx21"
            private_ip   = "10.0.0.6"
        }
        
        3 = {
            name = "node3"
            server_type = "cx21"
            private_ip   = "10.0.0.7"
        }
    }

    load_balancer = {
        type="lb11"
        private_ip="10.0.0.3"
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
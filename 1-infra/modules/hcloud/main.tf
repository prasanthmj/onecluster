
data "hcloud_network" "private_net" {
    name = var.network_name
}

resource "hcloud_server" "cloud_nodes" {
  for_each = var.nodes

  name        = each.value.name
  image       = "ubuntu-20.04" 
  server_type = each.value.server_type
  location    = var.hcloud_location
  ssh_keys    = ["hetzner1"]
}

resource "hcloud_volume" "volumes" {
  for_each = var.nodes
  
  name = "${each.value.name}-volx"
  size = 10
  server_id = hcloud_server.cloud_nodes[each.key].id
  automount = false
}

resource "hcloud_server_network" "server_network" {
  for_each = var.nodes

  network_id = data.hcloud_network.private_net.id
  server_id  = hcloud_server.cloud_nodes[each.key].id
  ip         = each.value.private_ip
}

resource "hcloud_load_balancer" "load_balancer" {
  name       = "${var.cluster_name}-lb"
  load_balancer_type = var.load_balancer.type
  location   = var.hcloud_location
  dynamic "target"{
    for_each = var.nodes
    content{
      type = "server"
      server_id= hcloud_server.cloud_nodes[target.key].id
    }
  }
}

resource "hcloud_load_balancer_network" "server_network_lb" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  network_id = data.hcloud_network.private_net.id
  ip = var.load_balancer.private_ip
}


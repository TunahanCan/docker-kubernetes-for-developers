resource "hcloud_network" "k8s" {
  name     = "k8s-network"
  ip_range = var.network_cidr
}

resource "hcloud_network_subnet" "k8s" {
  network_id   = hcloud_network.k8s.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = var.subnet_cidr
}

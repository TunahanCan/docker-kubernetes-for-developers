resource "hcloud_firewall" "k8s" {
  name = "k8s-firewall"

  # SSH
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Kubernetes API server
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "6443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # etcd
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "2379-2380"
    source_ips = [
      var.network_cidr
    ]
  }

  # Kubelet API
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "10250"
    source_ips = [
      var.network_cidr
    ]
  }

  # NodePort range
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "30000-32767"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Calico BGP
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "179"
    source_ips = [
      var.network_cidr
    ]
  }

  # Calico VXLAN
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "4789"
    source_ips = [
      var.network_cidr
    ]
  }
}

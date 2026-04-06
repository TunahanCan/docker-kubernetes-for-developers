# -----------------------------------------------------------------------------
# Control plane (master) node
# -----------------------------------------------------------------------------
resource "hcloud_server" "master" {
  name        = "k8s-master"
  image       = var.os_image
  server_type = var.master_server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.k8s.id]

  firewall_ids = [hcloud_firewall.k8s.id]

  user_data = templatefile("${path.module}/templates/master.yaml.tpl", {
    kubernetes_version = var.kubernetes_version
    pod_network_cidr   = var.pod_network_cidr
  })

  network {
    network_id = hcloud_network.k8s.id
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(pathexpand(var.ssh_private_key_path))
    host        = self.ipv4_address
  }

  # Wait for cloud-init to finish and join command to be ready
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to finish...'",
      "cloud-init status --wait",
      "echo 'Waiting for kubeadm join command file...'",
      "while [ ! -f /root/kubeadm_join_cmd.sh ]; do sleep 5; done",
      "echo 'Master is ready.'"
    ]
  }

  depends_on = [hcloud_network_subnet.k8s]
}

# -----------------------------------------------------------------------------
# Worker nodes
# -----------------------------------------------------------------------------
resource "hcloud_server" "worker" {
  count = var.worker_count

  name        = "k8s-worker-${count.index + 1}"
  image       = var.os_image
  server_type = var.worker_server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.k8s.id]

  firewall_ids = [hcloud_firewall.k8s.id]

  user_data = templatefile("${path.module}/templates/worker.yaml.tpl", {
    kubernetes_version = var.kubernetes_version
  })

  network {
    network_id = hcloud_network.k8s.id
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(pathexpand(var.ssh_private_key_path))
    host        = self.ipv4_address
  }

  # Wait for cloud-init to finish on worker
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to finish...'",
      "cloud-init status --wait",
      "echo 'Worker node preparation complete.'"
    ]
  }

  depends_on = [
    hcloud_network_subnet.k8s,
    hcloud_server.master,
  ]
}

# -----------------------------------------------------------------------------
# Join workers to the cluster via local-exec
# Fetches the join command from master, then executes it on each worker.
# -----------------------------------------------------------------------------
resource "null_resource" "worker_join" {
  count = var.worker_count

  triggers = {
    worker_id = hcloud_server.worker[count.index].id
    master_id = hcloud_server.master.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${pathexpand(var.ssh_private_key_path)}"
      JOIN_CMD=$(ssh $SSH_OPTS root@${hcloud_server.master.ipv4_address} 'cat /root/kubeadm_join_cmd.sh')
      echo "Joining worker ${count.index + 1} to the cluster..."
      ssh $SSH_OPTS root@${hcloud_server.worker[count.index].ipv4_address} "$JOIN_CMD"
      echo "Worker ${count.index + 1} joined successfully."
    EOT
  }

  depends_on = [
    hcloud_server.master,
    hcloud_server.worker,
  ]
}

# -----------------------------------------------------------------------------
# Pull kubeconfig to local machine
# -----------------------------------------------------------------------------
resource "null_resource" "kubeconfig" {
  triggers = {
    master_id = hcloud_server.master.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${pathexpand(var.ssh_private_key_path)}"
      ssh $SSH_OPTS root@${hcloud_server.master.ipv4_address} 'cat /root/.kube/config' \
        | sed "s|https://.*:6443|https://${hcloud_server.master.ipv4_address}:6443|" \
        > ${path.module}/kubeconfig.yaml
      echo "Kubeconfig saved to ${path.module}/kubeconfig.yaml"
    EOT
  }

  depends_on = [hcloud_server.master]
}

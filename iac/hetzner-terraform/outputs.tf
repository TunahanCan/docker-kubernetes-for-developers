output "master_public_ip" {
  description = "Public IP of the control plane node"
  value       = hcloud_server.master.ipv4_address
}

output "worker_public_ips" {
  description = "Public IPs of the worker nodes"
  value       = hcloud_server.worker[*].ipv4_address
}

output "ssh_to_master" {
  description = "SSH command to connect to the master node"
  value       = "ssh root@${hcloud_server.master.ipv4_address}"
}

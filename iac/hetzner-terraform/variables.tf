variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "fsn1"
}

variable "master_server_type" {
  description = "Server type for the control plane node"
  type        = string
  default     = "cpx22"
}

variable "worker_server_type" {
  description = "Server type for worker nodes"
  type        = string
  default     = "cpx22"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "os_image" {
  description = "OS image for all nodes"
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key to upload to Hetzner"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key for provisioner connections"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "network_zone" {
  description = "Hetzner network zone"
  type        = string
  default     = "eu-central"
}

variable "network_cidr" {
  description = "CIDR for the private network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "pod_network_cidr" {
  description = "CIDR for the Kubernetes pod network (Calico default)"
  type        = string
  default     = "192.168.0.0/16"
}

variable "kubernetes_version" {
  description = "Kubernetes minor version for apt repository"
  type        = string
  default     = "1.35"
}

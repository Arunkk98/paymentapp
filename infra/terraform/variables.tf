# Proxmox Provider Variables
variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token" {
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type    = string
  default = "pve"
}

variable "template_id" {
  type    = number
  default = 100
}

# Storage & Network Variables
variable "storage_datastore" {
  type    = string
  default = "hdd1tb"
}

variable "snippet_datastore" {
  type    = string
  default = "hdd1tb"
}

variable "network_bridge" {
  type    = string
  default = "vmbr0"
}

variable "network_gateway" {
  type    = string
  default = "192.168.1.1"
}

variable "dns_servers" {
  type    = list(string)
  default = ["1.1.1.1", "8.8.8.8"]
}

# Master Node Variables
variable "master_vm_name" {
  type    = string
  default = "k8s-master-01"
}

variable "master_hostname" {
  type    = string
  default = "k8s-master-01"
}

variable "master_vm_id" {
  type    = number
  default = 200
}

variable "master_ip" {
  type    = string
  default = "192.168.1.200"
}

variable "master_cpu_cores" {
  type    = number
  default = 2
}

variable "master_memory" {
  type    = number
  default = 2048
}

variable "master_disk_size" {
  type    = number
  default = 30
}

# Worker Nodes Variables
variable "worker_count" {
  type    = number
  default = 2
}

variable "worker_names" {
  type    = list(string)
  default = ["k8s-worker-01", "k8s-worker-02"]
}

variable "worker_hostnames" {
  type    = list(string)
  default = ["k8s-worker-01", "k8s-worker-02"]
}

variable "worker_ids" {
  type    = list(number)
  default = [201, 202]
}

variable "worker_ips" {
  type    = list(string)
  default = ["192.168.1.201", "192.168.1.202"]
}

variable "worker_cpu_cores" {
  type    = number
  default = 2
}

variable "worker_memory" {
  type    = number
  default = 4608
}

variable "worker_disk_size" {
  type    = number
  default = 50
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.66.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = var.proxmox_api_token
  insecure  = true

  ssh {
    agent    = true
    username = "root"
  }
}

data "local_file" "ssh_public_key" {
  filename = pathexpand("~/.ssh/id_rsa.pub")
}

resource "random_string" "cluster_token" {
  length  = 8
  special = false
}

# --- CLOUD-INIT SNIPPETS ---

resource "proxmox_virtual_environment_file" "cloud_init_master" {
  content_type = "snippets"
  datastore_id = var.snippet_datastore
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/cloud-init.tpl", {
      hostname       = var.master_hostname
      ssh_public_key = chomp(data.local_file.ssh_public_key.content)
    })
    file_name = "cloud-init-master-${random_string.cluster_token.result}.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_workers" {
  count        = var.worker_count
  content_type = "snippets"
  datastore_id = var.snippet_datastore
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/cloud-init.tpl", {
      hostname       = var.worker_hostnames[count.index]
      ssh_public_key = chomp(data.local_file.ssh_public_key.content)
    })
    file_name = "cloud-init-worker-${count.index}-${random_string.cluster_token.result}.yaml"
  }
}

# --- MASTER VM ---

resource "proxmox_virtual_environment_vm" "k8s_master" {
  name        = var.master_vm_name
  description = "Kubernetes Master Node - Control Plane"
  tags        = ["k8s", "master", "production"]

  node_name = var.proxmox_node
  vm_id     = var.master_vm_id

  clone {
    vm_id = var.template_id
    full  = true
  }

  agent { enabled = true }

  cpu {
    cores = var.master_cpu_cores
    type  = "host"
  }

  memory { dedicated = var.master_memory }

  disk {
    datastore_id = var.storage_datastore
    interface    = "scsi0"
    size         = var.master_disk_size
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.master_ip}/24"
        gateway = var.network_gateway
      }
    }
    dns { servers = var.dns_servers }
    user_data_file_id = proxmox_virtual_environment_file.cloud_init_master.id
  }
}

# --- WORKER VMs ---

resource "proxmox_virtual_environment_vm" "k8s_workers" {
  count       = var.worker_count
  name        = var.worker_names[count.index]
  description = "Kubernetes Worker Node ${count.index + 1}"
  tags        = ["k8s", "worker", "production"]

  node_name = var.proxmox_node
  vm_id     = var.worker_ids[count.index]

  clone {
    vm_id = var.template_id
    full  = true
  }

  agent { enabled = true }

  cpu {
    cores = var.worker_cpu_cores
    type  = "host"
  }

  memory { dedicated = var.worker_memory }

  disk {
    datastore_id = var.storage_datastore
    interface    = "scsi0"
    size         = var.worker_disk_size
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.worker_ips[count.index]}/24"
        gateway = var.network_gateway
      }
    }
    dns { servers = var.dns_servers }
    user_data_file_id = proxmox_virtual_environment_file.cloud_init_workers[count.index].id
  }
}

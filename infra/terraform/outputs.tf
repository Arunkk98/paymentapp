output "master_ip" {
  description = "IP address of the control plane node"
  value       = var.master_ip
}

output "worker_ips" {
  description = "IP addresses of all worker nodes"
  value       = var.worker_ips
}

output "ssh_connections" {
  description = "SSH quick connections"
  value = concat(
    ["ssh root@${var.master_ip}"],
    [for ip in var.worker_ips : "ssh root@${ip}"]
  )
}

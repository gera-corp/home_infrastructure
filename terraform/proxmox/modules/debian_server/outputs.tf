output "clone" {
  description = "Template name that this VM was cloned from."
  value       = [for server in proxmox_virtual_environment_vm.debian_server : server.clone[0].vm_id]
}

output "vm_id" {
  description = "The VM Id."
  value       = [for server in proxmox_virtual_environment_vm.debian_server : server.vm_id]
}

output "vm_name" {
  description = "The VM name."
  value       = [for server in proxmox_virtual_environment_vm.debian_server : server.name]
}

output "ip" {
  description = "Template name that this VM was cloned from."
  value       = [for server in proxmox_virtual_environment_vm.debian_server : server.initialization[0].ip_config[0].ipv4[0].address]
}

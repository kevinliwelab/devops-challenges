output "bastion_ip" {
  description = "Bastion Node Public IP"
  value       = module.bastion_instance.public_ip
}

output "vm_ip" {
  description = "VM Instance Private IP"
  value       = module.vm_instance.private_ip
}

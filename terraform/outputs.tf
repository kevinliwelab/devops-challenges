output "bastion_ip" {
  description = "Bastion Node Public IP"
  value       = module.bastion_instance.public_ip
}

output "public_vm_external_ip" {
  value = yandex_compute_instance.public_vm.network_interface[0].nat_ip_address
}

output "public_vm_internal_ip" {
  value = yandex_compute_instance.public_vm.network_interface[0].ip_address
}
output "private_vm_internal_ip" {
  value = yandex_compute_instance.private_vm.network_interface[0].ip_address
}
output "load_balancer_ip" {
  value = tolist(tolist(yandex_lb_network_load_balancer.lamp_lb.listener)[0].external_address_spec)[0].address
}
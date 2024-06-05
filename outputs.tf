output "awx_access" {
  value = "Access AWX via browser http://${ibm_is_floating_ip.awx_instance.address}"
}

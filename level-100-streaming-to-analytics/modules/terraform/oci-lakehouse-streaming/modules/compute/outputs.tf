output "compute_public_ip" {
  value = oci_core_instance.compute.public_ip
}

output "application_id" {
  value = oci_functions_application.application.id
}

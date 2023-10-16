output "sch_id" {
  value = oci_sch_service_connector.service_connector.id
}
output "function_id" {
  value = data.oci_functions_functions.functions.functions[0].id
}

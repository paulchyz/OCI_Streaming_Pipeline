output "datascience_model_id" {
  value = oci_datascience_model.id
}
output "datascience_model_deployment_id" {
  value = oci_datascience_model_deployment.id
}
output "datascience_model_deployment_url" {
  value = oci_datascience_model_deployment.model_deployment_url
}
output "datascience_notebook_session_id" {
  value = var.datascience_notebook_session_is_deployed ? oci_datascience_notebook_session.datascience_notebook_session[0].id : null
}

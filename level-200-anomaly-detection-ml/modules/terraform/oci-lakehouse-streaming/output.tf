output "random_string" {
  value = random_string.random.id
}
output "iam_compartment_id" {
  value = module.iam.iam_compartment_id
}
output "iam_compartment_name" {
  value = module.iam.iam_compartment_name
}
output "iam_policy_id" {
  value = var.iam_policy_is_deployed ? module.iam.iam_policy_id : null
}
output "ads_project_id" {
  value = var.ads_is_deployed ? module.ads[0].ads_project_id : null
}
output "adb_id" {
  value = var.adb_is_deployed ? module.adb[0].adb_id : null
}
output "adb_db_name" {
  value = var.adb_is_deployed ? local.autonomous_database_db_name : null
}
output "adb_ords_url" {
  value = var.adb_is_deployed ? module.adb[0].adb_ords_url : null
}
output "compute_public_ip" {
  value = var.compute_is_deployed ? module.compute[0].compute_public_ip : null
}
output "datascience_model_id" {
  value = var.datascience_is_deployed ? module.datascience[0].datascience_model_id : null
}
output "datascience_model_deployment_id" {
  value = var.datascience_is_deployed ? module.datascience[0].datascience_model_deployment_id : null
}
output "datascience_model_deployment_url" {
  value = var.datascience_is_deployed ? module.datascience[0].datascience_model_deployment_url : null
}
output "datascience_notebook_session_id" {
  value = var.datascience_is_deployed && var.datascience_notebook_session_is_deployed ? module.ods[0].datascience_notebook_session_id : null
}
output "function_id" {
  value = var.sch_is_deployed ? module.sch[0].function_id : null
}
output "application_id" {
  value = var.compute_is_deployed ? module.compute[0].application_id : null
}
output "object_storage_bucket_id_unprocessed" {
  value = var.object_storage_is_deployed ? module.object_storage[0].object_storage_bucket_id_unprocessed : null
}
output "object_storage_bucket_name_unprocessed" {
  value = var.object_storage_is_deployed ? module.object_storage[0].object_storage_bucket_name_unprocessed : null
}
output "object_storage_bucket_id_processed" {
  value = var.object_storage_is_deployed ? module.object_storage[0].object_storage_bucket_id_processed : null
}
output "object_storage_bucket_name_processed" {
  value = var.object_storage_is_deployed ? module.object_storage[0].object_storage_bucket_name_processed : null
}
output "ons_topic_id" {
  value = var.ons_is_deployed ? module.ons[0].ons_topic_id : null
}
output "ons_subscription_id" {
  value = var.ons_is_deployed ? module.ons[0].ons_subscription_id : null
}
output "sch_id" {
  value = var.sch_is_deployed ? module.sch[0].sch_id : null
}
output "stream_pool_id" {
  value = var.streaming_is_deployed ? module.streaming[0].stream_pool_id : null
}
output "stream_id" {
  value = var.streaming_is_deployed ? module.streaming[0].stream_id : null
}
output "stream_messages_endpoint" {
  value = var.streaming_is_deployed ? module.streaming[0].stream_messages_endpoint : null
}
output "vcn_id" {
  value = var.vcn_is_deployed ? module.vcn[0].vcn_id : null
}

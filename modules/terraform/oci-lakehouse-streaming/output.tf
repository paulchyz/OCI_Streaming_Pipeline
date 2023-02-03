output "iam_compartment_id" {
  value = module.iam.iam_compartment_id
}
output "iam_compartment_name" {
  value = module.iam.iam_compartment_name
}
output "iam_policy_id" {
  value = var.iam_policy_is_deployed ? module.iam.iam_policy_id : null
}
# output "iam_dynamic_group_id" {
#   value = var.iam_policy_is_deployed ? module.iam.iam_dynamic_group_id : null
# }
output "ads_project_id" {
  value = var.ads_is_deployed ? module.ads[0].ads_project_id : null
}
output "adw_id" {
  value = var.adw_is_deployed ? module.adw[0].adw_id : null
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
output "ods_notebook_session_id" {
  value = var.ods_is_deployed ? module.ods[0].ods_notebook_session_id : null
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
output "vcn_id" {
  value = var.vcn_is_deployed ? module.vcn[0].vcn_id : null
}

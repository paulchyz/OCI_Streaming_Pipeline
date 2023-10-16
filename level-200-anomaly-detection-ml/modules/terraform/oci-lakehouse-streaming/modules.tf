module "iam" {
  providers = {
    oci = oci.home
  }
  source = "./modules/iam"
  # configuration
  parent_compartment_id                  = var.parent_compartment_id
  iam_compartment_description            = var.iam_compartment_description
  iam_compartment_name                   = local.iam_compartment_name
  iam_compartment_enable_delete          = var.iam_compartment_enable_delete
  iam_policy_is_deployed                 = var.iam_policy_is_deployed
  iam_policy_name                        = local.iam_policy_name
  iam_policy_description                 = var.iam_policy_description
  tenancy_ocid                           = var.tenancy_ocid
  object_storage_bucket_name_unprocessed = local.object_storage_bucket_name_unprocessed
  object_storage_bucket_name_processed   = local.object_storage_bucket_name_processed
  adb_is_deployed                        = var.adb_is_deployed
  sch_is_deployed                        = var.sch_is_deployed
  compute_is_deployed                    = var.compute_is_deployed
  vcn_is_deployed                        = var.vcn_is_deployed
  #stream_id                              = var.streaming_is_deployed ? module.streaming[0].stream_id : null
  streaming_is_deployed = var.streaming_is_deployed
}

module "compute" {
  depends_on = [module.iam, module.datascience]
  count      = var.compute_is_deployed ? 1 : 0
  providers = {
    oci = oci.custom
  }
  source = "./modules/compute"
  # configuration
  # streaming compute bootstrap
  STREAMING_unique_id                  = random_string.random.id
  STREAMING_ocir_user_password         = var.STREAMING_ocir_user_password
  STREAMING_ocir_user_name             = var.STREAMING_ocir_user_name
  STREAMING_region_id                  = var.region_custom
  STREAMING_app_compartment_id         = local.new_compartment_id
  compute_compartment_id               = local.new_compartment_id
  compute_shape                        = var.compute_shape
  compute_ad_number                    = var.compute_ad_number
  compute_ssh_key_public               = var.compute_ssh_key_public
  compute_subnet_id                    = module.vcn[0].public_subnet_id
  app_subnet_id                        = module.vcn[0].private_subnet_id
  autonomous_database_admin_password   = var.autonomous_database_admin_password
  object_storage_bucket_name_processed = local.object_storage_bucket_name_processed
  adb_ords_url                         = module.adb[0].adb_ords_url
  STREAMING_MESSAGES_ENDPOINT          = module.streaming[0].stream_messages_endpoint
  STREAMING_STREAM_OCID                = module.streaming[0].stream_id
  model_endpoint_url                   = module.datascience[0].datascience_model_deployment_url
}

module "datascience" {
  depends_on = [module.iam]
  providers = {
    oci = oci.custom
  }
  count  = var.datascience_is_deployed ? 1 : 0
  source = "./modules/datascience"
  # configuration
  compartment_id                                         = local.new_compartment_id
  datascience_project_description                        = var.datascience_project_description
  datascience_project_display_name                       = var.datascience_project_display_name
  datascience_model_display_name                         = local.datascience_model_display_name
  datascience_model_deployment_display_name              = local.datascience_model_deployment_display_name
  datascience_model_deployment_shape                     = var.datascience_model_deployment_shape
  datascience_notebook_session_is_deployed               = var.datascience_notebook_session_is_deployed
  datascience_notebook_session_display_name              = var.datascience_notebook_session_display_name
  datascience_notebook_session_shape                     = var.datascience_notebook_session_shape
  datascience_notebook_session_ocpu                      = var.datascience_notebook_session_ocpu
  datascience_notebook_session_memory_in_gb              = var.datascience_notebook_session_memory_in_gb
  datascience_notebook_session_block_storage_size_in_gbs = var.datascience_notebook_session_block_storage_size_in_gbs
}

module "adb" {
  depends_on = [module.iam]
  providers = {
    oci = oci.custom
  }
  count  = var.adb_is_deployed ? 1 : 0
  source = "./modules/adb"
  # configuration
  autonomous_database_admin_password           = var.autonomous_database_admin_password
  autonomous_database_cpu_core_count           = var.autonomous_database_cpu_core_count
  autonomous_database_db_version               = var.autonomous_database_db_version
  autonomous_database_is_auto_scaling_enabled  = var.autonomous_database_is_auto_scaling_enabled
  autonomous_database_data_storage_size_in_tbs = var.autonomous_database_data_storage_size_in_tbs
  autonomous_database_display_name             = var.autonomous_database_display_name
  autonomous_database_db_name                  = local.autonomous_database_db_name
  autonomous_database_db_workload              = var.autonomous_database_db_workload
  autonomous_database_license_model            = var.autonomous_database_license_model
  autonomous_database_data_safe_status         = var.autonomous_database_data_safe_status
  autonomous_database_whitelisted_ips          = var.autonomous_database_whitelisted_ips
  compartment_id                               = local.new_compartment_id
}

module "object_storage" {
  depends_on = [module.iam]
  providers = {
    oci = oci.custom
  }
  count  = var.object_storage_is_deployed ? 1 : 0
  source = "./modules/object_storage"
  # configuration
  object_storage_bucket_name_unprocessed         = local.object_storage_bucket_name_unprocessed
  object_storage_bucket_access_type_unprocessed  = var.object_storage_bucket_access_type_unprocessed
  object_storage_bucket_storage_tier_unprocessed = var.object_storage_bucket_storage_tier_unprocessed
  object_storage_bucket_versioning_unprocessed   = var.object_storage_bucket_versioning_unprocessed
  object_storage_bucket_name_processed           = local.object_storage_bucket_name_processed
  object_storage_bucket_access_type_processed    = var.object_storage_bucket_access_type_processed
  object_storage_bucket_storage_tier_processed   = var.object_storage_bucket_storage_tier_processed
  object_storage_bucket_versioning_processed     = var.object_storage_bucket_versioning_processed
  compartment_id                                 = local.new_compartment_id
  tenancy_ocid                                   = var.tenancy_ocid
}

module "ons" {
  depends_on = [module.iam]
  providers = {
    oci = oci.custom
  }
  count  = var.ons_is_deployed ? 1 : 0
  source = "./modules/ons"
  #configuration
  compartment_id            = local.new_compartment_id
  ons_topic_name            = local.ons_topic_name
  ons_subscription_endpoint = var.ons_subscription_endpoint
  ons_subscription_protocol = var.ons_subscription_protocol
}

module "sch" {
  depends_on = [module.iam, module.compute]
  providers = {
    oci = oci.custom
  }
  count  = var.sch_is_deployed ? 1 : 0
  source = "./modules/sch"

  compartment_ocid                       = local.new_compartment_id
  sch_display_name                       = var.sch_display_name
  stream_id                              = module.streaming[0].stream_id
  sch_application_id                     = module.compute[0].application_id
  sch_batch_size_in_kbs                  = var.sch_batch_size_in_kbs
  sch_batch_time_in_sec                  = var.sch_batch_time_in_sec
  object_storage_bucket_name_unprocessed = module.object_storage[0].object_storage_bucket_name_unprocessed
  sch_batch_rollover_size_in_mbs         = var.sch_batch_rollover_size_in_mbs
  sch_batch_rollover_time_in_ms          = var.sch_batch_rollover_time_in_ms
}

module "streaming" {
  depends_on = [module.iam]
  providers = {
    oci = oci.custom
  }
  count  = var.streaming_is_deployed ? 1 : 0
  source = "./modules/streaming"
  # configuration
  stream_name               = var.stream_name
  stream_partitions         = var.stream_partitions
  stream_retention_in_hours = var.stream_retention_in_hours
  stream_pool_name          = var.stream_pool_name
  compartment_id            = local.new_compartment_id
}

module "vcn" {
  depends_on = [module.iam]
  providers = {
    oci = oci.custom
  }
  count  = var.vcn_is_deployed ? 1 : 0
  source = "./modules/vcn"
  # configuration
  vcn_display_name = var.vcn_display_name
  vcn_dns_label    = var.vcn_dns_label
  ig_display_name  = var.ig_display_name
  ng_display_name  = var.ng_display_name
  service_id       = data.oci_core_services.services.services.0.id
  service_cidr     = data.oci_core_services.services.services.0.cidr_block
  sg_display_name  = var.sg_display_name
  vcn_cidrs        = var.vcn_cidrs
  compartment_id   = local.new_compartment_id
}

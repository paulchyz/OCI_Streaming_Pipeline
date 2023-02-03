# AUTH
variable "tenancy_ocid" { default = "" }
variable "user_ocid" { default = "" }
variable "fingerprint" { default = "" }
variable "private_key_path" { default = "" }
variable "region" { default = "" }

# naming
variable "name_for_resources" { default = "SamCac" }

# iam
variable "parent_compartment_id" { default = "" }
variable "iam_compartment_name" { default = "ST_workshop" }
variable "iam_compartment_description" { default = "Compartment for Streaming Pipeline workshop" }
variable "iam_compartment_enable_delete" { default = true }
variable "iam_policy_is_deployed" { default = false }
variable "iam_policy_name" { default = "ST_policy" }
variable "iam_policy_description" { default = "Policy for Streaming Pipeline workshop" }
# variable "iam_dynamic_group_name" { default = "ST_dynamic_group" }
# variable "iam_dynamic_group_description" { default = "Dynamic Group for Streaming Pipeline workshop" }

# ads
variable "ads_is_deployed" { default = false }
variable "ads_project_description" { default = "Project container for Anomaly Detection models" }
variable "ads_project_display_name" { default = "ST_model_project" }

# adw
variable "adw_is_deployed" { default = true }
# The password must be between 12 and 30 characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol (") or the username "admin", regardless of casing.
variable "autonomous_database_admin_password" {
  default   = "Welcome!2345"
  sensitive = true
}
variable "autonomous_database_cpu_core_count" { default = 1 }
variable "autonomous_database_db_version" { default = "19c" }
variable "autonomous_database_is_auto_scaling_enabled" { default = false }
variable "autonomous_database_data_storage_size_in_tbs" { default = 1 }
variable "autonomous_database_display_name" { default = "ST_ADW" }
variable "autonomous_database_db_name" { default = "stadw" } # The name must begin with an alphabetic character and can contain a maximum of 14 alphanumeric characters. Special characters are not permitted. The database name must be unique in the tenancy.
variable "autonomous_database_db_workload" { default = "DW" }
variable "autonomous_database_license_model" { default = "LICENSE_INCLUDED" }
variable "autonomous_database_data_safe_status" { default = "NOT_REGISTERED" }
variable "autonomous_database_whitelisted_ips" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

# functions
# variable "fnc_is_deployed" { default = true }
# variable "fnc_app_display_name" { default = "ST_app" }
# variable "fnc_display_name" { default = "ST_" }
# variable "fnc_memory_in_mbs" { default = 256 }
# variable "fnc_subnet_app_cidr" { default = "10.0.30.0/24" }
# variable "fnc_subnet_app_display_name" { default = "ST_fnc_subnet_app" }
# variable "fnc_subnet_app_dns_label" { default = "fncsubapp" }
# variable "fnc_app_rt_display_name" { default = "ST_fnc_route_table" }
# variable "fnc_app_sl_display_name" { default = "ST_fnc_security_list" }
# variable "fnc_ocir_repo_name" { default = "samcac" }
# variable "fnc_ocir_user_name" { default = "oracleidentitycloudservice/samuel.cacela@oracle.com" }
# variable "fnc_ocir_user_password" { default = "S(>7Vk>.1XI>J60NSgii" }

# object_storage
variable "object_storage_is_deployed" { default = false }
variable "object_storage_bucket_name_unprocessed" { default = "ST_bucket_unprocessed" }
variable "object_storage_bucket_access_type_unprocessed" { default = "NoPublicAccess" }
variable "object_storage_bucket_storage_tier_unprocessed" { default = "Standard" }
variable "object_storage_bucket_versioning_unprocessed" { default = "Disabled" }
variable "object_storage_bucket_name_processed" { default = "ST_bucket_processed" }
variable "object_storage_bucket_access_type_processed" { default = "NoPublicAccess" }
variable "object_storage_bucket_storage_tier_processed" { default = "Standard" }
variable "object_storage_bucket_versioning_processed" { default = "Disabled" }

# ods
variable "ods_is_deployed" { default = false }
variable "ods_project_display_name" { default = "ST_data_science_project" }
variable "ods_notebook_session_display_name" { default = "ST_data_science_notebook_session" }
variable "ods_notebook_session_shape" { default = "VM.Standard.E3.Flex" }
variable "ods_notebook_session_ocpu" { default = 2 }
variable "ods_notebook_session_memory_in_gb" { default = 32 }
variable "ods_notebook_session_block_storage_size_in_gbs" { default = 50 }

# ons
variable "ons_is_deployed" { default = false }
variable "ons_topic_name" { default = "ST_ons_topic" }
variable "ons_subscription_endpoint" { default = "" }
variable "ons_subscription_protocol" { default = "EMAIL" }

# sch
variable "sch_is_deployed" { default = false }
variable "sch_display_name" { default = "ST_sch" }
variable "sch_batch_size_in_kbs" { default = 5120 }
variable "sch_batch_time_in_sec" { default = 60 }
variable "sch_batch_rollover_size_in_mbs" { default = 100 }
variable "sch_batch_rollover_time_in_ms" { default = 60000 }
variable "sch_function_id" { default = "" }

# streaming
variable "streaming_is_deployed" { default = true }
variable "stream_pool_name" { default = "ST_stream_pool" }
variable "stream_name" { default = "ST_stream" }
variable "stream_partitions" { default = 1 }
variable "stream_retention_in_hours" { default = 168 }

# vcn
variable "vcn_is_deployed" { default = true }
variable "vcn_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}
variable "vcn_display_name" { default = "ST_vcn" }
variable "vcn_dns_label" { default = "stvcn" }
variable "ig_display_name" { default = "ST_internet_gateway" }
variable "ng_display_name" { default = "ST_nat_gateway" }
variable "sg_display_name" { default = "ST_service_gateway" }

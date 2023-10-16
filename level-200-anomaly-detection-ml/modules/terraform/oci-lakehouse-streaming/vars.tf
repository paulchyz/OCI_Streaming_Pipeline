# AUTH
variable "tenancy_ocid" { default = "" }
variable "user_ocid" { default = "" }
variable "fingerprint" { default = "" }
variable "private_key_path" { default = "" }
variable "region_home" { default = "" }
variable "region_custom" { default = "" }

# iam
variable "parent_compartment_id" { default = "" }
variable "iam_compartment_name" { default = "ST_workshop" }
variable "iam_compartment_description" { default = "Compartment for Streaming Pipeline workshop" }
variable "iam_compartment_enable_delete" { default = true }
variable "iam_policy_is_deployed" { default = false }
variable "iam_policy_name" { default = "ST_policy" }
variable "iam_policy_description" { default = "Policy for Streaming Pipeline workshop" }

# datascience
variable "datascience_is_deployed" { default = false }
variable "datascience_project_description" { default = "Project container for Data Science resources" }
variable "datascience_project_display_name" { default = "ST_model_project" }
variable "datascience_model_display_name" { default = "model" }
variable "datascience_model_deployment_display_name" { default = "model_deployment" }
variable "datascience_model_deployment_shape" { default = "VM.Standard.E4.Flex" }
variable "datascience_model_deployment_ocpu" { default = 1 }
variable "datascience_model_deployment_memory_in_gb" { default = 16 }
variable "datascience_notebook_session_is_deployed" { default = false }
variable "datascience_notebook_session_display_name" { default = "ST_data_science_notebook_session" }
variable "datascience_notebook_session_shape" { default = "VM.Standard.E3.Flex" }
variable "datascience_notebook_session_ocpu" { default = 2 }
variable "datascience_notebook_session_memory_in_gb" { default = 32 }
variable "datascience_notebook_session_block_storage_size_in_gbs" { default = 50 }

# adw
variable "adb_is_deployed" { default = true }
# The password must be between 12 and 30 characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol (") or the username "admin", regardless of casing.
variable "autonomous_database_admin_password" {
  default   = "Streaming!2345"
  sensitive = true
}
variable "autonomous_database_cpu_core_count" { default = 1 }
variable "autonomous_database_db_version" { default = "19c" }
variable "autonomous_database_is_auto_scaling_enabled" { default = false }
variable "autonomous_database_data_storage_size_in_tbs" { default = 1 }
variable "autonomous_database_display_name" { default = "ST_AJD" }
variable "autonomous_database_db_name" { default = "stajd" } # The name must begin with an alphabetic character and can contain a maximum of 14 alphanumeric characters. Special characters are not permitted. The database name must be unique in the tenancy.
variable "autonomous_database_db_workload" { default = "AJD" }
variable "autonomous_database_license_model" { default = "LICENSE_INCLUDED" }
variable "autonomous_database_data_safe_status" { default = "NOT_REGISTERED" }
variable "autonomous_database_whitelisted_ips" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

# compute

# streaming compute bootstrap
variable "compute_is_deployed" { default = true }
variable "STREAMING_ocir_user_password" { default = "" }
variable "STREAMING_ocir_user_name" { default = "" }

# streaming compute
variable "compute_shape" { default = "VM.StandardE4.Flex" }
variable "compute_ad_number" { default = 1 }
variable "compute_ssh_key_public" {
  type    = string
  default = ""
}

# object_storage
variable "object_storage_is_deployed" { default = false }
variable "object_storage_bucket_name_unprocessed" { default = "ST_bucket_raw" }
variable "object_storage_bucket_access_type_unprocessed" { default = "NoPublicAccess" }
variable "object_storage_bucket_storage_tier_unprocessed" { default = "Standard" }
variable "object_storage_bucket_versioning_unprocessed" { default = "Disabled" }
variable "object_storage_bucket_name_processed" { default = "ST_bucket" }
variable "object_storage_bucket_access_type_processed" { default = "NoPublicAccess" }
variable "object_storage_bucket_storage_tier_processed" { default = "Standard" }
variable "object_storage_bucket_versioning_processed" { default = "Disabled" }

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
  default = ["10.0.0.0/16", "10.1.0.0/16"]
}
variable "vcn_display_name" { default = "ST_vcn" }
variable "vcn_dns_label" { default = "stvcn" }
variable "ig_display_name" { default = "ST_internet_gateway" }
variable "ng_display_name" { default = "ST_nat_gateway" }
variable "sg_display_name" { default = "ST_service_gateway" }

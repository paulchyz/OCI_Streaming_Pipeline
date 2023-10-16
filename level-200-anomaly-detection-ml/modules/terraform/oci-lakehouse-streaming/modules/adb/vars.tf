variable "autonomous_database_admin_password" {}
variable "autonomous_database_cpu_core_count" {}
variable "autonomous_database_db_version" {}
variable "autonomous_database_is_auto_scaling_enabled" {}
variable "autonomous_database_data_storage_size_in_tbs" {}
variable "autonomous_database_display_name" {}
variable "autonomous_database_db_name" {}
variable "autonomous_database_db_workload" {}
variable "autonomous_database_license_model" {}
variable "autonomous_database_data_safe_status" {}
variable "autonomous_database_whitelisted_ips" {}
variable "compartment_id" {}

terraform {
  required_providers {
    oci = {
      source  = "hashicorp/oci"
    }
  }
}
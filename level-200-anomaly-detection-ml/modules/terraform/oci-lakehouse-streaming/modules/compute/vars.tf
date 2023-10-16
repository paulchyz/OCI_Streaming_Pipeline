variable "STREAMING_unique_id" {}
variable "STREAMING_ocir_user_password" {}
variable "STREAMING_ocir_user_name" {}
variable "STREAMING_region_id" {}
variable "STREAMING_app_compartment_id" {}
variable "compute_compartment_id" {}
variable "compute_shape" {}
variable "compute_ad_number" {}
variable "compute_ssh_key_public" {}
variable "compute_subnet_id" {}
variable "app_subnet_id" {}
variable "autonomous_database_admin_password" {}
variable "object_storage_bucket_name_processed" {}
variable "adb_ords_url" {}
variable "STREAMING_MESSAGES_ENDPOINT" {}
variable "STREAMING_STREAM_OCID" {}
variable "model_endpoint_url" {}

terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
    }
  }
}

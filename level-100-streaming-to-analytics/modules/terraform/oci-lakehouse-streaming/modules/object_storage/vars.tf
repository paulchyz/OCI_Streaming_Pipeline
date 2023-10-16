variable "compartment_id" {}
variable "object_storage_bucket_name_unprocessed" {}
variable "object_storage_bucket_access_type_unprocessed" {}
variable "object_storage_bucket_storage_tier_unprocessed" {}
variable "object_storage_bucket_versioning_unprocessed" {}
variable "object_storage_bucket_name_processed" {}
variable "object_storage_bucket_access_type_processed" {}
variable "object_storage_bucket_storage_tier_processed" {}
variable "object_storage_bucket_versioning_processed" {}
variable "tenancy_ocid" {}

terraform {
  required_providers {
    oci = {
      source  = "hashicorp/oci"
    }
  }
}
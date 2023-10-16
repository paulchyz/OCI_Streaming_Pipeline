variable "parent_compartment_id" {}
variable "iam_compartment_name" {}
variable "iam_compartment_description" {}
variable "iam_compartment_enable_delete" {}
variable "iam_policy_is_deployed" {}
variable "iam_policy_name" {}
variable "iam_policy_description" {}
variable "tenancy_ocid" {}
variable "ods_is_deployed" {}
variable "ads_is_deployed" {}
variable "object_storage_bucket_name_unprocessed" {}
variable "object_storage_bucket_name_processed" {}
variable "adb_is_deployed" {}
variable "sch_is_deployed" {}
variable "streaming_is_deployed" {}
variable "compute_is_deployed" {}
variable "vcn_is_deployed" {}
#variable "stream_id" {}

terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
    }
  }
}

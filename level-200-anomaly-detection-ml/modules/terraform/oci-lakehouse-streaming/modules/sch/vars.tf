variable "compartment_ocid" {}
variable "sch_display_name" {}
variable "stream_id" {}
variable "sch_application_id" {}
variable "sch_batch_size_in_kbs" {}
variable "sch_batch_time_in_sec" {}
variable "object_storage_bucket_name_unprocessed" {}
variable "sch_batch_rollover_size_in_mbs" {}
variable "sch_batch_rollover_time_in_ms" {}

terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
    }
  }
}

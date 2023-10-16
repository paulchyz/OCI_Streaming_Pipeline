variable "vcn_cidrs" {}
variable "compartment_id" {}
variable "vcn_display_name" {}
variable "vcn_dns_label" {}
variable "ig_display_name" {}
variable "ng_display_name" {}
variable "service_id" {}
variable "service_cidr" {}
variable "sg_display_name" {}

terraform {
  required_providers {
    oci = {
      source  = "hashicorp/oci"
    }
  }
}
variable "compartment_id" {}
variable "ons_topic_name" {}
variable "ons_subscription_endpoint" {}
variable "ons_subscription_protocol" {}

terraform {
  required_providers {
    oci = {
      source  = "hashicorp/oci"
    }
  }
}
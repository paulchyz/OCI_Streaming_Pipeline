variable "compartment_id" {}
variable "ads_project_description" {}
variable "ads_project_display_name" {}

terraform {
  required_providers {
    oci = {
      source  = "hashicorp/oci"
    }
  }
}

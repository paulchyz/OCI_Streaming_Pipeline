provider "oci" {
  alias = "home"
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
  region = var.region_home
  disable_auto_retries = false
}

provider "oci" {
  alias = "custom"
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
  region = var.region_custom
  disable_auto_retries = false
}
# availability domains
data "oci_identity_availability_domains" "compute_ads" {
  compartment_id = var.compute_compartment_id
}

# fault domains
data "oci_identity_fault_domains" "compute_fds" {
  availability_domain = local.ad_name
  compartment_id      = var.compute_compartment_id
}
# images (compute)
data "oci_core_images" "compute_images" {
  compartment_id   = var.compute_compartment_id
  operating_system = "Oracle Linux"
  sort_by          = "TIMECREATED"
  sort_order       = "DESC"
}

# object storage
data "oci_objectstorage_namespace" "namespace" {

  #Optional
  compartment_id = var.compute_compartment_id
}

# regions
data "oci_identity_regions" "available_regions" {
  filter {
    name   = "name"
    values = [var.STREAMING_region_id]
    regex  = false
  }
}

# wait for bootstrapping to complete
resource "time_sleep" "wait_for_bootstrapping" {
  depends_on = [oci_core_instance.compute]

  create_duration = "600s"
}

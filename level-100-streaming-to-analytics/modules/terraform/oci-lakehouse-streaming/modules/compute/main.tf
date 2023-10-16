# compute instance
resource "oci_core_instance" "compute" {
  depends_on          = [oci_functions_application.application]
  availability_domain = local.ad_name
  compartment_id      = var.compute_compartment_id
  display_name        = "compute_${var.STREAMING_unique_id}"
  shape               = "VM.Standard.E4.Flex"
  shape_config {
    memory_in_gbs = 16
    ocpus         = 1
  }
  create_vnic_details {
    subnet_id        = var.compute_subnet_id
    assign_public_ip = true
    hostname_label   = "compute${var.STREAMING_unique_id}"
  }
  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.compute_images.images.0.id
  }
  metadata = {
    ssh_authorized_keys = var.compute_ssh_key_public
    user_data           = local.cloud_init_gzip
  }
}

resource "oci_functions_application" "application" {
  compartment_id = var.STREAMING_app_compartment_id
  display_name   = "streaming_app"
  subnet_ids     = [var.app_subnet_id]
  config = { "json-collection-name" : "STREAMDATA",
    "db-schema" : "admin",
    "db-user" : "admin",
    "dbpwd-cipher" : var.autonomous_database_admin_password,
    "streaming-bucket-processed" : var.object_storage_bucket_name_processed,
  "ords-base-url" : var.adb_ords_url }
}

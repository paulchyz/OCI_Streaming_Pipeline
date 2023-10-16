data "oci_core_services" "services" {
  provider = oci.custom

  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

data "oci_objectstorage_namespace" "namespace" {
  compartment_id = var.parent_compartment_id
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.parent_compartment_id
}

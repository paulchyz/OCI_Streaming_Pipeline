resource "oci_objectstorage_bucket" "object_storage_bucket_unprocessed" {
    #Required
    compartment_id = var.compartment_id
    name = var.object_storage_bucket_name_unprocessed
    namespace = data.oci_objectstorage_namespace.namespace.namespace

    #Optional
    access_type = var.object_storage_bucket_access_type_unprocessed
    storage_tier = var.object_storage_bucket_storage_tier_unprocessed
    versioning = var.object_storage_bucket_versioning_unprocessed
}

resource "oci_objectstorage_bucket" "object_storage_bucket_processed" {
    #Required
    compartment_id = var.compartment_id
    name = var.object_storage_bucket_name_processed
    namespace = data.oci_objectstorage_namespace.namespace.namespace

    #Optional
    access_type = var.object_storage_bucket_access_type_processed
    storage_tier = var.object_storage_bucket_storage_tier_processed
    versioning = var.object_storage_bucket_versioning_processed
}
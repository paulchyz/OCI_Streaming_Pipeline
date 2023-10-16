locals {
  # region_key = lower(data.oci_identity_regions.available_regions.regions.0.key)

  new_compartment_id = module.iam.iam_compartment_id

  # add petnames to resources that must be unique within the tenancy
  iam_compartment_name                   = "${var.iam_compartment_name}_${random_string.random.id}"
  iam_policy_name                        = "${var.iam_policy_name}_${random_string.random.id}"
  ons_topic_name                         = "${var.ons_topic_name}_${random_string.random.id}"
  object_storage_bucket_name_unprocessed = "${var.object_storage_bucket_name_unprocessed}_${random_string.random.id}"
  object_storage_bucket_name_processed   = "${var.object_storage_bucket_name_processed}_${random_string.random.id}"
  autonomous_database_db_name            = join("", [substr(var.autonomous_database_db_name, 0, 10), random_string.random.id])
}

# random string as a unique identifier for resources
resource "random_string" "random" {
  length  = 4
  special = false
  lower   = true
  upper   = false
  numeric = true
}
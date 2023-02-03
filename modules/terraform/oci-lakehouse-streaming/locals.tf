locals {
  region_key = lower(data.oci_identity_regions.available_regions.regions.0.key)

  new_compartment_id = module.iam.iam_compartment_id

  # add petnames to resources that must be unique within the tenancy
  iam_compartment_name                   = "${var.iam_compartment_name}_${random_pet.random_pet_name.id}"
  iam_policy_name                        = "${var.iam_policy_name}_${random_pet.random_pet_name.id}"
  iam_dynamic_group_name                 = "${var.iam_dynamic_group_name}_${random_pet.random_pet_name.id}"
  ons_topic_name                         = "${var.ons_topic_name}_${random_pet.random_pet_name.id}"
  object_storage_bucket_name_unprocessed = "${var.object_storage_bucket_name_unprocessed}_${random_pet.random_pet_name.id}"
  object_storage_bucket_name_processed   = "${var.object_storage_bucket_name_processed}_${random_pet.random_pet_name.id}"
  autonomous_database_db_name            = substr(replace("${var.autonomous_database_db_name}_${random_pet.random_pet_name.id}", "_", ""), 0, 14)
}

resource "random_pet" "random_pet_name" {
  length    = 2
  separator = "_"
  prefix    = var.name_for_resources
}

resource "oci_identity_compartment" "compartment" {
  #Required
  compartment_id = var.parent_compartment_id
  description    = var.iam_compartment_description
  name           = var.iam_compartment_name
  enable_delete  = var.iam_compartment_enable_delete
}

resource "oci_identity_policy" "policy" {
  count = var.iam_policy_is_deployed && local.iam_policy_statements_is_deployed ? 1 : 0
  #Required
  compartment_id = var.parent_compartment_id
  description    = var.iam_policy_description
  name           = var.iam_policy_name
  statements     = local.iam_policy_statements
}

resource "time_sleep" "wait_after_compartment_creation" {
  depends_on = [oci_identity_compartment.compartment]

  create_duration = "60s"
}

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
  compartment_id = var.tenancy_ocid
  description    = var.iam_policy_description
  name           = var.iam_policy_name
  statements     = local.iam_policy_statements
}

# # remove Dynamic Group from logic

# resource "oci_identity_dynamic_group" "dynamic_group" {
#   depends_on = [oci_identity_compartment.compartment]
#   count      = var.iam_policy_is_deployed && local.iam_dynamic_group_matching_rule_is_deployed ? 1 : 0
#   #Required
#   compartment_id = var.tenancy_ocid
#   description    = var.iam_dynamic_group_description
#   matching_rule  = local.iam_dynamic_group_matching_rule
#   name           = var.iam_dynamic_group_name
# }

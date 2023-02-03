output "iam_compartment_id" {
  value = oci_identity_compartment.compartment.id
}
output "iam_compartment_name" {
  value = oci_identity_compartment.compartment.name
}
output "iam_policy_id" {
  value = var.iam_policy_is_deployed && local.iam_policy_statements_is_deployed ? oci_identity_policy.policy[0].id : null
}
# output "iam_dynamic_group_id" {
#   value = var.iam_policy_is_deployed && local.iam_dynamic_group_matching_rule_is_deployed ? oci_identity_dynamic_group.dynamic_group[0].id : null
# }

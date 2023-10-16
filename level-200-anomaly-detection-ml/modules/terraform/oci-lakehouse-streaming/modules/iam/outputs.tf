output "iam_compartment_id" {
  value = oci_identity_compartment.compartment.id
}
output "iam_compartment_name" {
  value = oci_identity_compartment.compartment.name
}
output "iam_policy_id" {
  value = var.iam_policy_is_deployed && local.iam_policy_statements_is_deployed ? oci_identity_policy.policy[0].id : null
}

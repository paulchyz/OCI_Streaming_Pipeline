# # fix these policies:
# locals {
#   iam_policy_statements_ods = var.ods_is_deployed ? ["Allow dynamic-group ${var.iam_dynamic_group_name} to manage data-science-family in compartment id ${oci_identity_compartment.compartment.id}",
#     "Allow dynamic-group ${var.iam_dynamic_group_name} to manage object-family in compartment id ${oci_identity_compartment.compartment.id}",
#     "Allow dynamic-group ${var.iam_dynamic_group_name} to use virtual-network-family in compartment id ${oci_identity_compartment.compartment.id}",
#   "Allow service datascience to use virtual-network-family in compartment id ${oci_identity_compartment.compartment.id}"] : []
#   iam_policy_statements_ads         = var.ads_is_deployed ? ["Allow dynamic-group ${var.iam_dynamic_group_name} to manage ai-service-anomaly-detection-family in compartment id ${oci_identity_compartment.compartment.id}"] : []
#   iam_policy_statements             = flatten([local.iam_policy_statements_ods, local.iam_policy_statements_ads])
#   iam_policy_statements_is_deployed = var.ods_is_deployed || var.ads_is_deployed ? true : false # add conditions using logical OR as additional modules require Dynamic Group membership

#   iam_dynamic_group_matching_rule_ods         = var.ods_is_deployed ? ["datasciencemodeldeployment.compartment.id='${oci_identity_compartment.compartment.id}', datasciencejobrun.compartment.id='${oci_identity_compartment.compartment.id}', datasciencenotebooksession.compartment.id='${oci_identity_compartment.compartment.id}'"] : []
#   iam_dynamic_group_matching_rule_is_deployed = var.ods_is_deployed ? true : false # add conditions using logical OR as additional modules require Dynamic Group membership
#   iam_dynamic_group_matching_rule             = local.iam_dynamic_group_matching_rule_is_deployed ? "Any {${flatten([local.iam_dynamic_group_matching_rule_ods])[0]}}" : null
# }


locals {
  iam_policy_statements_is_deployed = var.sch_is_deployed || var.adw_is_deployed ? true : false

  iam_policy_statements_sch = var.sch_is_deployed ? ["Allow any-user to use objects in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='serviceconnector', target.bucket.name=${var.object_storage_bucket_name_unprocessed}, request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}",
    "Allow any-user to manage objects in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='fnfunc', any{target.bucket.name='${var.object_storage_bucket_name_processed}', target.bucket.name='${var.object_storage_bucket_name_processed}'}, request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}",
    "Allow any-user to {STREAM_READ, STREAM_CONSUME} in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='serviceconnector', target.stream.id='ocid1.stream.oc1.iad.amaaaaaawe6j4fqavg5sle6ozxslpj2zmu4eewjubcv7psuocfr5jehlcmvq', request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}",
    "Allow any-user to use fn-function in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='serviceconnector', request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}",
  "Allow any-user to use fn-invocation in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='serviceconnector', request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}"] : []
  iam_policy_statements_adw = var.adw_is_deployed ? ["Allow any-user to use objects in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='autonomousdatabase', request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}",
  "Allow any-user to use autonomous-database-family in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='fnfunc', any{target.bucket.name='${var.object_storage_bucket_name_processed}', target.bucket.name='${var.object_storage_bucket_name_processed}'}, request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}"] : []
  iam_policy_statements = flatten([local.iam_policy_statements_sch, local.iam_policy_statements_adw])
}

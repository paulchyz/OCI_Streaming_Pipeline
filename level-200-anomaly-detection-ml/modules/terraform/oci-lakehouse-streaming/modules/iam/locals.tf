locals {
  iam_policy_statements_is_deployed = (var.sch_is_deployed && var.streaming_is_deployed) || var.adb_is_deployed || var.compute_is_deployed ? true : false

  iam_policy_statements_sch = var.sch_is_deployed ? ["Allow any-user to manage objects in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='serviceconnector', target.bucket.name='${var.object_storage_bucket_name_unprocessed}', request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}",
    "Allow any-user to manage objects in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='fnfunc', target.bucket.name='${var.object_storage_bucket_name_processed}', request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}",
    "Allow any-user to use fn-function in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='serviceconnector', request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}",
  "Allow any-user to use fn-invocation in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='serviceconnector', request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}"] : []

  iam_policy_statements_streaming = var.sch_is_deployed && var.streaming_is_deployed ? ["Allow any-user to {STREAM_READ, STREAM_CONSUME} in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='serviceconnector', target.stream.compartment.id='${oci_identity_compartment.compartment.id}', request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}",
  "Allow any-user to manage stream-family in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='instance', request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}"] : []

  iam_policy_statements_adb = var.adb_is_deployed ? ["Allow any-user to use objects in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='autonomousdatabase', request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}",
  "Allow any-user to use autonomous-database-family in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='fnfunc', request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}"] : []

  iam_policy_statements_compute = var.compute_is_deployed ? ["Allow any-user to manage functions-family in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='instance', request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}",
    "Allow any-user to manage repos in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='instance', request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}",
  "Allow any-user to read objectstorage-namespaces in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.type='instance', request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}"] : []

  # to do: replace with less permissive policy statement
  catchall_policy_statement = ["Allow any-user to manage all-resources in compartment id ${oci_identity_compartment.compartment.id} where all {request.principal.compartment.id='${oci_identity_compartment.compartment.id}'}"]

  iam_policy_statements = flatten([local.iam_policy_statements_sch, local.iam_policy_statements_streaming, local.iam_policy_statements_adb, local.iam_policy_statements_compute, local.catchall_policy_statement])
}

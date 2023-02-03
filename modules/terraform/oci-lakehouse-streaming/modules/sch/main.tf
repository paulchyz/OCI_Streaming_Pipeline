resource "oci_sch_service_connector" "service_connector" {
  compartment_id = var.compartment_ocid
  display_name   = var.sch_display_name

  # If using streaming source
  source {
    kind      = "Streaming"
    stream_id = var.stream_id
  }

  # If using function task
  tasks {
    function_id       = var.sch_function_id
    kind              = "function"
    batch_size_in_kbs = var.sch_batch_size_in_kbs
    batch_time_in_sec = var.sch_batch_time_in_sec
  }

  # If using the objectStorage target
  target {
    kind                       = "objectStorage"
    bucket                     = var.object_storage_bucket_name_unprocessed
    batch_rollover_size_in_mbs = var.sch_batch_rollover_size_in_mbs
    batch_rollover_time_in_ms  = var.sch_batch_rollover_time_in_ms
  }

  state = "ACTIVE"
}

resource "oci_datascience_project" "ods_project" {
    #Required
    compartment_id = var.compartment_id
    #Optional
    display_name = var.ods_project_display_name
}

resource "oci_datascience_notebook_session" "ods_notebook_session" {
    #Required
    compartment_id = var.compartment_id
    notebook_session_config_details {
        #Required
        shape = var.ods_notebook_session_shape

        #Optional
        block_storage_size_in_gbs = var.ods_notebook_session_block_storage_size_in_gbs
        dynamic notebook_session_shape_config_details {
            for_each = var.ods_notebook_session_shape == "VM.Standard.E3.Flex" || var.ods_notebook_session_shape == "VM.Standard.E4.Flex" ? [1] : []
            content {
            memory_in_gbs = var.ods_notebook_session_memory_in_gb
            ocpus = var.ods_notebook_session_ocpu
            }
        }
    }
    project_id = oci_datascience_project.ods_project.id
    display_name = var.ods_notebook_session_display_name
}
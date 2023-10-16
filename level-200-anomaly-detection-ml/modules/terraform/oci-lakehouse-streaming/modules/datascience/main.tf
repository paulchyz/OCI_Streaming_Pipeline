resource "oci_datascience_project" "project" {
  #Required
  compartment_id = var.compartment_id
  display_name   = var.datascience_project_display_name
  description    = var.datascience_project_description
}

resource "oci_datascience_model" "model" {
  depends_on = [oci_datascience_project.project]
  #Required
  compartment_id               = var.compartment_id
  project_id                   = oci_datascience_project.project.id
  display_name                 = var.datascience_model_display_name
  model_artifact               = "./artifact_boilerplate.zip"
  artifact_content_disposition = "attachment; filename=artifact_boilerplate.zip"
  artifact_content_length      = 22798 # number of bytes in model_artifact file, required
}

resource "oci_datascience_model_deployment" "model_deployment" {
  depends_on = [oci_datascience_project.project, oci_datascience_model.model]

  timeouts {
    create = "40m" # Timeout for resource creation
    update = "40m" # Timeout for resource updates
    delete = "40m" # Timeout for resource deletion
  }
  #Required
  compartment_id = var.compartment_id
  model_deployment_configuration_details {
    #Required
    deployment_type = "SINGLE_MODEL"
    model_configuration_details {
      #Required
      instance_configuration {
        #Required
        instance_shape_name = var.datascience_model_deployment_shape

        #Optional
        model_deployment_instance_shape_config_details {

          #Optional
          memory_in_gbs = 16
          ocpus         = 1
        }
      }
      model_id = oci_datascience_model.model.id
    }
  }
  project_id   = oci_datascience_project.project.id
  display_name = var.datascience_model_deployment_display_name
}

resource "oci_datascience_notebook_session" "datascience_notebook_session" {
  count = var.datascience_notebook_session_is_deployed ? 1 : 0
  #Required
  compartment_id = var.compartment_id
  notebook_session_config_details {
    #Required
    shape = var.datascience_notebook_session_shape

    #Optional
    block_storage_size_in_gbs = var.datascience_notebook_session_block_storage_size_in_gbs
    dynamic "notebook_session_shape_config_details" {
      for_each = var.datascience_notebook_session_shape == "VM.Standard.E3.Flex" || var.datascience_notebook_session_shape == "VM.Standard.E4.Flex" ? [1] : []
      content {
        memory_in_gbs = var.datascience_notebook_session_memory_in_gb
        ocpus         = var.datascience_notebook_session_ocpu
      }
    }
  }
  project_id   = oci_datascience_project.project.id
  display_name = var.datascience_notebook_session_display_name
}

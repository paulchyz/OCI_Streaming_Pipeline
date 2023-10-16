locals {
  ad_name = data.oci_identity_availability_domains.compute_ads.availability_domains[var.compute_ad_number - 1]["name"]
}
locals {
  STREAMING_function_name  = "streaming_fnc_${var.STREAMING_unique_id}"
  STREAMING_ocir_namespace = data.oci_objectstorage_namespace.namespace.namespace
  STREAMING_region_id      = var.STREAMING_region_id #data.oci_identity_regions.available_regions.regions.0.name
  STREAMING_region_key     = lower(data.oci_identity_regions.available_regions.regions.0.key)
}

locals {
  cloud_init_parts = [
    {
      filepath     = "${path.module}/bootstrap_compute.sh"
      content-type = "text/x-shellscript"
      vars = {
        STREAMING_function_name      = local.STREAMING_function_name
        STREAMING_ocir_user_password = var.STREAMING_ocir_user_password
        STREAMING_ocir_user_name     = var.STREAMING_ocir_user_name
        STREAMING_ocir_namespace     = local.STREAMING_ocir_namespace
        STREAMING_region_id          = local.STREAMING_region_id
        STREAMING_region_key         = local.STREAMING_region_key
        STREAMING_app_compartment_id = var.STREAMING_app_compartment_id
        STREAMING_MESSAGES_ENDPOINT  = var.STREAMING_MESSAGES_ENDPOINT
        STREAMING_STREAM_OCID        = var.STREAMING_STREAM_OCID
      }
    }
  ]
}

locals {
  cloud_init_parts_rendered = [for part in local.cloud_init_parts : <<-EOF
--MIMEBOUNDARY
Content-Transfer-Encoding: 7bit
Content-Type: ${part.content-type}
Mime-Version: 1.0

${templatefile(part.filepath, part.vars)}
    EOF
  ]
}

locals {
  cloud_init_gzip = base64gzip(templatefile("${path.module}/cloud-init.tpl", { cloud_init_parts = local.cloud_init_parts_rendered }))
}

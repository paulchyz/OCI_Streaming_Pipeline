resource "oci_ai_anomaly_detection_project" "ads_project" {
    #Required
    compartment_id = var.compartment_id
    #Optional
    description = var.ads_project_description
    display_name = var.ads_project_display_name
}
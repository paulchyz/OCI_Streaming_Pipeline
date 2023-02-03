resource "oci_database_autonomous_database" "adw" {
    #Required
    compartment_id = var.compartment_id
    db_name = var.autonomous_database_db_name

    #Optional
    admin_password = var.autonomous_database_admin_password
    cpu_core_count = var.autonomous_database_cpu_core_count
    data_storage_size_in_tbs = var.autonomous_database_data_storage_size_in_tbs
    db_version = var.autonomous_database_db_version
    data_safe_status = var.autonomous_database_data_safe_status
    db_workload = var.autonomous_database_db_workload
    display_name = var.autonomous_database_display_name
    is_auto_scaling_enabled = var.autonomous_database_is_auto_scaling_enabled
    license_model = var.autonomous_database_license_model   
    whitelisted_ips = var.autonomous_database_whitelisted_ips
}
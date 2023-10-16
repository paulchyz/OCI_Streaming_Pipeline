output "adb_id" {
  value = oci_database_autonomous_database.adb.id
}

output "adb_ords_url" {
  value = regex("(.*/)apex$", lower(oci_database_autonomous_database.adb.connection_urls[0].apex_url))[0]
}

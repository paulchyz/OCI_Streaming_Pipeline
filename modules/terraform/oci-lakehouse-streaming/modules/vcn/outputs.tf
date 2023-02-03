output "vcn_id" {
  value = oci_core_vcn.vcn.id
}
output "vcn_default_dhcp_options_id" {
  value = oci_core_vcn.vcn.default_dhcp_options_id
}
output "ig_id" {
  value = oci_core_internet_gateway.ig.id
}
output "ng_id" {
  value = oci_core_nat_gateway.ng.id
}
output "sg_id" {
  value = oci_core_service_gateway.sg.id
}
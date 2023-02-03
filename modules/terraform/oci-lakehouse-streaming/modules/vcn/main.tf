resource "oci_core_vcn" "vcn" {
  cidr_blocks    = var.vcn_cidrs
  compartment_id = var.compartment_id
  display_name   = var.vcn_display_name
  dns_label      = var.vcn_dns_label
}
resource "oci_core_internet_gateway" "ig" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = var.ig_display_name
}
# NAT gateway allows one way outbound internet traffic
resource "oci_core_nat_gateway" "ng" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = var.ng_display_name
}
# Service gateway allows database server access to object storage object_storage_bucket for backups
resource "oci_core_service_gateway" "sg" {
  compartment_id = var.compartment_id
  services {
    service_id = var.service_id
  }
  display_name = var.sg_display_name
  vcn_id       = oci_core_vcn.vcn.id
}

# Private Subnet
resource "oci_core_subnet" "subnet" {
  count                      = local.subnet_count
  cidr_block                 = cidrsubnet(oci_core_vcn.vcn.cidr_blocks[0], log(local.num_subnet_partitions, 2), count.index)
  display_name               = "Subnet${count.index + 1}"
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.vcn.id
  route_table_id             = oci_core_route_table.rt.id
  security_list_ids          = [oci_core_security_list.sl.id]
  prohibit_public_ip_on_vnic = false
  dns_label                  = "subnet${count.index + 1}"
}

# Route Table
resource "oci_core_route_table" "rt" {
  count          = local.subnet_count
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "RouteTable"

  route_rules {
    network_entity_id = oci_core_nat_gateway.ng.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    description       = "traffic to/from NAT Gateway"
  }
  route_rules {
    network_entity_id = oci_core_service_gateway.sg.id
    destination       = var.service_cidr
    destination_type  = "SERVICE_CIDR_BLOCK"
    description       = "traffic to/from Service Gateway"
  }
}

# Security List
resource "oci_core_security_list" "sl" {
  count          = local.subnet_count
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "SecurityList${count.index + 1}"

  # outbound traffic
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  # inbound traffic
  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }
}

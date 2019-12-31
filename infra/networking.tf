# Configure the Virtual Cloud Network
resource "oci_core_vcn" "dad-jokes" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.project_compartment_ocid
  display_name   = "Dad Jokes"
  dns_label      = "dadjokes"
}

# Configure the Internet Gateway
resource "oci_core_internet_gateway" "dad-jokes" {
  compartment_id = var.project_compartment_ocid
  vcn_id         = oci_core_vcn.dad-jokes.id
  display_name   = "Dad Jokes"
}

# Configure the Route Table
resource "oci_core_route_table" "dad-jokes" {
  compartment_id = var.project_compartment_ocid
  display_name   = "Dad Jokes"

  route_rules {
    cidr_block        = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.dad-jokes.id
  }

  vcn_id = oci_core_vcn.dad-jokes.id
}

# Configure the Subnet
resource "oci_core_subnet" "dad-jokes" {
  cidr_block                 = "10.0.0.0/16"
  compartment_id             = var.project_compartment_ocid
  dhcp_options_id            = oci_core_vcn.dad-jokes.default_dhcp_options_id
  display_name               = "Dad Jokes"
  dns_label                  = "dadjokes"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_route_table.dad-jokes.id
  security_list_ids          = [
    oci_core_vcn.dad-jokes.default_security_list_id,
    oci_core_security_list.accept-https-traffic.id
  ]
  vcn_id                     = oci_core_vcn.dad-jokes.id
}

resource "oci_core_security_list" "accept-https-traffic" {
  display_name   = "Incoming HTTPS traffic for Functions application"
  compartment_id = var.project_compartment_ocid
  vcn_id         = oci_core_vcn.dad-jokes.id

  # HTTPS traffic
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }
}
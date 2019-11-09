variable "user_ocid" {}                # OCID of your tenancy
variable "tenancy_ocid" {}             # OCID of the user calling the API
variable "compartment_ocid" {}         # OCID of your root Comparment
variable "fingerprint" {}              # Fingerprint for the key pair being used
variable "private_key_path" {}         # The path (including filename) of the private key stored on your computer
variable "private_key_password" {}     # Passphrase used for the key, if it is encrypted.
variable "region" {}                   # An Oracle Cloud Infrastructure region
variable "project_compartment_ocid" {} # OCID for the compartment where this project lives

# Fetch Availability Domains
data "oci_identity_availability_domains" "my-availability-domain" {
  compartment_id = "${var.tenancy_ocid}"
}

# Fetch compartments
data "oci_identity_compartment" "project-compartment" {
    id = "${var.project_compartment_ocid}"
}

# Configure the Oracle Cloud Infrastructure provider
provider "oci" {
    tenancy_ocid = "${var.tenancy_ocid}"
    user_ocid = "${var.user_ocid}"
    fingerprint = "${var.fingerprint}"
    private_key_path = "${var.private_key_path}"
    private_key_password = "${var.private_key_password}"
    region = "${var.region}"
}

# Configure the Virtual Cloud Network
resource "oci_core_vcn" "dad-jokes" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = "${var.project_compartment_ocid}"
  display_name   = "Dad Jokes"
  dns_label      = "dadjokes"
}

# Configure the Internet Gateway
resource "oci_core_internet_gateway" "dad-jokes" {
  compartment_id = "${var.project_compartment_ocid}"
  vcn_id         = "${oci_core_vcn.dad-jokes.id}"
  display_name   = "Dad Jokes"
}

# Configure the Route Table
resource "oci_core_route_table" "dad-jokes" {
  compartment_id = "${var.project_compartment_ocid}"
  display_name = "Dad Jokes"

  route_rules {
    cidr_block        = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.dad-jokes.id}"
  }

  vcn_id = "${oci_core_vcn.dad-jokes.id}"
}

# Configure the Subnet
resource "oci_core_subnet" "dad-jokes" {
  availability_domain        = "${lower("${data.oci_identity_availability_domains.my-availability-domain.availability_domains.2.name}")}"
  cidr_block                 = "10.0.0.0/16"
  compartment_id             = "${var.project_compartment_ocid}"
  dhcp_options_id            = "${oci_core_vcn.dad-jokes.default_dhcp_options_id}"
  display_name               = "Dad Jokes"
  dns_label                  = "dadjokes"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = "${oci_core_route_table.dad-jokes.id}"
  security_list_ids          = ["${oci_core_vcn.dad-jokes.default_security_list_id}"]
  vcn_id                     = "${oci_core_vcn.dad-jokes.id}"
}

# Configure the Application
resource "oci_functions_application" "dad-jokes" {
    compartment_id = "${var.project_compartment_ocid}"
    display_name = "Dad-Jokes"
    subnet_ids = ["${oci_core_subnet.dad-jokes.id}"]
}

# Finally, configure the Function
resource "oci_functions_function" "get-joke" {
  application_id = "${oci_functions_application.dad-jokes.id}"
  display_name   = "Get-Joke"
  image          = "fra.ocir.io/frwqejk9in9h/dad-jokes/get-joke:0.0.1"
  memory_in_mbs  = "128"
}

# Describe the group of users that can work with the function 
resource "oci_identity_group" "dad-jokes" {
    compartment_id = "${var.compartment_ocid}"
    description = "Dad Jokes users"
    name = "dad-jokes"
}

resource "oci_identity_policy" "create-required-policies" {
    compartment_id = "${var.compartment_ocid}"
    description = "Grant necessary rights to dad-jokes group"
    name = "grant-dad-jokes-group-rights"
    statements = [
      "Allow group ${oci_identity_group.dad-jokes.name} to use repos in tenancy",
      "Allow group ${oci_identity_group.dad-jokes.name} to read metrics in compartment ${data.oci_identity_compartment.project-compartment.name}",
      "Allow group ${oci_identity_group.dad-jokes.name} to use virtual-network-family in compartment ${data.oci_identity_compartment.project-compartment.name}",
      "Allow group ${oci_identity_group.dad-jokes.name} to manage all-resources in compartment ${data.oci_identity_compartment.project-compartment.name}",
      "Allow service FaaS to use virtual-network-family in compartment ${data.oci_identity_compartment.project-compartment.name}",
      "Allow service FaaS to read repos in tenancy"
    ]
}

output "Get-Jokes-Endpoint" {
  value = "${oci_functions_function.get-joke.invoke_endpoint}"
}

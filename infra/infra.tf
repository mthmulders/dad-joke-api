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
  compartment_id = var.tenancy_ocid
}

# Fetch compartments
data "oci_identity_compartment" "project-compartment" {
  id = var.project_compartment_ocid
}

# Configure the Oracle Cloud Infrastructure provider
provider "oci" {
  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  private_key_password = var.private_key_password
  region               = var.region
}

# Describe the group of users that can work with the function 
resource "oci_identity_group" "dad-jokes" {
  compartment_id = var.compartment_ocid
  description    = "Dad Jokes users"
  name           = "dad-jokes"
}

resource "oci_identity_policy" "create-policies-for-users" {
  compartment_id = var.compartment_ocid
  description    = "Grant necessary rights to dad-jokes group"
  name           = "create-policies-for-users"
  statements = [
    "Allow group ${oci_identity_group.dad-jokes.name} to manage repos in tenancy",
    "Allow group ${oci_identity_group.dad-jokes.name} to read metrics in compartment ${data.oci_identity_compartment.project-compartment.name}",
    "Allow group ${oci_identity_group.dad-jokes.name} to use virtual-network-family in compartment ${data.oci_identity_compartment.project-compartment.name}",
    "Allow group ${oci_identity_group.dad-jokes.name} to manage all-resources in compartment ${data.oci_identity_compartment.project-compartment.name}",
    "Allow service FaaS to use virtual-network-family in compartment ${data.oci_identity_compartment.project-compartment.name}",
    "Allow service FaaS to read repos in tenancy"
  ]
}

resource "oci_identity_policy" "create-policies-for-resources" {
  compartment_id = var.compartment_ocid
  description    = "Grant necessary rights to resources inside project"
  name           = "create-policies-for-resource"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.api-gateway.name} to use virtual-network-family in compartment ${data.oci_identity_compartment.project-compartment.name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.api-gateway.name} to manage public-ips in compartment ${data.oci_identity_compartment.project-compartment.name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.api-gateway.name} to use functions-family in compartment ${data.oci_identity_compartment.project-compartment.name}"
  ]
}

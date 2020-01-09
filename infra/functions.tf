# Configure the Application
resource "oci_functions_application" "dad-jokes" {
  compartment_id = var.project_compartment_ocid
  display_name   = "Dad-Jokes"
  subnet_ids     = [oci_core_subnet.dad-jokes.id]
}

# Finally, configure the Function
resource "oci_functions_function" "get-joke" {
  application_id = oci_functions_application.dad-jokes.id
  display_name   = "get-joke"
  image          = "fra.ocir.io/frwqejk9in9h/dad-jokes/get-joke:0.0.9"
  memory_in_mbs  = "128"
}

output "Get-Jokes-Internal-Endpoint" {
  value = oci_functions_function.get-joke.invoke_endpoint
}

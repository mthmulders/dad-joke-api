resource "oci_apigateway_gateway" "dad-joke-gateway" {
  compartment_id = var.project_compartment_ocid
  endpoint_type  = "PUBLIC"
  display_name   = "Dad Jokes Gateway"
  subnet_id      = oci_core_subnet.dad-jokes.id
}

resource "oci_apigateway_deployment" "get-joke" {
  compartment_id = var.project_compartment_ocid
  gateway_id     = oci_apigateway_gateway.dad-joke-gateway.id
  path_prefix    = "/v1"
  display_name   = "Get Joke"
  specification {
    logging_policies {
      access_log {
        is_enabled = true
      }
      execution_log {
        is_enabled = true
        log_level  = "INFO"
      }
    }
    routes {
      backend {
        type        = "ORACLE_FUNCTIONS_BACKEND"
        function_id = oci_functions_function.get-joke.id
      }
      logging_policies {
        access_log {
          is_enabled = true
        }
        execution_log {
          is_enabled = true
          log_level  = "INFO"
        }
      }
      path    = "/joke"
      methods = ["GET"]
    }
  }
}

resource "oci_identity_dynamic_group" "api-gateway" {
  compartment_id = var.compartment_ocid
  description    = "Dynamic group for API Gateway"
  matching_rule  = "all { resource.type = 'ApiGateway', resource.compartment.id = '${var.project_compartment_ocid}' }"
  name           = "api-gateway"
}

output "Get-Jokes-Public-Endpoint" {
  value = "${oci_apigateway_deployment.get-joke.endpoint}${oci_apigateway_deployment.get-joke.specification[0].routes[0].path}"
}

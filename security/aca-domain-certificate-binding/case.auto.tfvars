aca = {
  app_name              = "relay-api-prod"
  origin_hostname       = "relay-api-prod.internal.example"
  public_network_access = "Disabled"
  custom_domain = {
    hostname                  = "relay-api-origin.example.com"
    certificate_name          = "relay-api-origin-cert"
    domain_control_validation = "HTTP"
  }
}

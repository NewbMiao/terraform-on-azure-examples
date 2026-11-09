locals {
  aca_custom_domain_enabled = try(var.aca.custom_domain, null) != null
}

resource "terraform_data" "aca_environment" {
  # Azure resource: azurerm_container_app_environment
  input = {
    app_name              = var.aca.app_name
    origin_hostname       = var.aca.origin_hostname
    public_network_access = var.aca.public_network_access
  }
}

resource "terraform_data" "aca_managed_certificate" {
  # Azure resource: azapi_resource Microsoft.App/managedEnvironments/managedCertificates
  count = local.aca_custom_domain_enabled ? 1 : 0

  input = {
    name                      = var.aca.custom_domain.certificate_name
    subject_name              = var.aca.custom_domain.hostname
    domain_control_validation = var.aca.custom_domain.domain_control_validation
    owner                     = "aca"
  }
}

resource "terraform_data" "aca_custom_domain" {
  # Azure resource: azurerm_container_app_custom_domain
  count = local.aca_custom_domain_enabled ? 1 : 0

  input = {
    hostname    = var.aca.custom_domain.hostname
    certificate = terraform_data.aca_managed_certificate[0].output.name
    owner       = "aca"
  }

  depends_on = [terraform_data.aca_managed_certificate]
}

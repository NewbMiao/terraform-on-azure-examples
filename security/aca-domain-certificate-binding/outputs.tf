output "aca" {
  value = {
    environment = terraform_data.aca_environment.output
    certificate = local.aca_custom_domain_enabled ? terraform_data.aca_managed_certificate[0].output : null
    domain      = local.aca_custom_domain_enabled ? terraform_data.aca_custom_domain[0].output : null
  }
}


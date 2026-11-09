output "waf" {
  value = {
    domain = terraform_data.waf_aca_custom_domain.output
    origin = terraform_data.waf_aca_origin.output
    route  = terraform_data.waf_aca_route.output
  }
}

resource "terraform_data" "waf_aca_custom_domain" {
  # Azure resource: azurerm_cdn_frontdoor_custom_domain
  input = {
    hostname = var.waf.public_hostname
    profile  = var.waf.profile
    backend  = var.aca.app_name
    owner    = "waf"
  }
}

resource "terraform_data" "waf_aca_origin" {
  # Azure resource: azurerm_cdn_frontdoor_origin
  input = {
    hostname     = var.aca.origin_hostname
    private_link = true
    backend      = var.aca.app_name
  }
}

resource "terraform_data" "waf_aca_route" {
  # Azure resource: azurerm_cdn_frontdoor_route
  input = {
    custom_domain = terraform_data.waf_aca_custom_domain.output.hostname
    origin        = terraform_data.waf_aca_origin.output.hostname
    protocol      = "HttpsOnly"
  }

  depends_on = [
    terraform_data.waf_aca_custom_domain,
    terraform_data.waf_aca_origin,
  ]
}

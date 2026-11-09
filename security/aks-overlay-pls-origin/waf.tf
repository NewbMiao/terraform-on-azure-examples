resource "terraform_data" "pls_ingress" {
  # Azure resource: azurerm_private_link_service
  # Actually created by the cluster cloud controller from the annotations in k8s/ingress-nginx-controller-service.yaml
  input = {
    name         = var.pls.name
    node_subnet  = var.cluster.node_subnet_name
    request_note = var.pls.request_note
    source       = "k8s/ingress-nginx-controller-service.yaml"
  }

  depends_on = [terraform_data.aks_cluster]
}

resource "terraform_data" "waf_custom_domain" {
  # Azure resource: azurerm_cdn_frontdoor_custom_domain
  input = {
    hostname = var.waf.public_hostname
    profile  = var.waf.profile
    owner    = "waf" # hostname and certificate belong to the edge
  }
}

resource "terraform_data" "waf_origin" {
  # Azure resource: azurerm_cdn_frontdoor_origin
  input = {
    hostname            = var.waf.public_hostname
    private_link        = true
    private_link_target = terraform_data.pls_ingress.output.name # the PLS, not a subnet or ILB
  }
}

resource "terraform_data" "waf_route" {
  # Azure resource: azurerm_cdn_frontdoor_route
  input = {
    custom_domain = terraform_data.waf_custom_domain.output.hostname
    origin        = terraform_data.waf_origin.output.hostname
    protocol      = "HttpsOnly"
  }

  depends_on = [
    terraform_data.waf_custom_domain,
    terraform_data.waf_origin,
  ]
}

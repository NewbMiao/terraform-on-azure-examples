# Fictional subscription and subnet IDs (00000000-…); public IPs are mapped by locals
# to the documentation range 198.51.100.0/24.
# Mirrors the lesson step that adds aca_crest_prd for crest after "folding into env-shared"
# (before that, subnet_keys could be [] with only include_ado_agent).
#
# ado_agent = Azure DevOps self-hosted agent elastic pool subnet (ADO, not AKS).
# This example only demonstrates ACA third-party egress registration; AKS node subnets
# don't ride the env-shared NAT (they have their own LB outbound).

network_subnet_ids = {
  "eg_vnet_apac_prd/ado_agent"     = "/subscriptions/00000000-0000-0000-0000-000000000101/resourceGroups/RG-EG-PROD-NET-SEA/providers/Microsoft.Network/virtualNetworks/VNET-EG-PROD-SEA-01/subnets/SNET-EG-PROD-ADO-AGENT"
  "eg_vnet_apac_prd/aca_crest_prd" = "/subscriptions/00000000-0000-0000-0000-000000000101/resourceGroups/RG-EG-PROD-NET-SEA/providers/Microsoft.Network/virtualNetworks/VNET-EG-PROD-SEA-01/subnets/SNET-EG-PROD-ACA-CREST"
}

shared_nat_gateways = {
  app_prd_sea = {
    subscription_key    = "prod"
    vnet_key            = "eg_vnet_apac_prd"
    resource_group_name = "RG-EG-PROD-NET-SEA"
    location            = "southeastasia"
    name                = "nat-eg-app-prod-sea"
    public_ips = {
      "01" = { name = "pip-nat-eg-app-prod-sea-01" }
    }
    subnet_keys = [
      "aca_crest_prd",
    ]
    include_ado_agent = true
  }
}

egress_allowlist = {
  crest_third_party_callback = {
    consumer_label  = "crest-prod-aca-partner-callback"
    nat_gateway_key = "app_prd_sea"
    public_ip_key   = "01"
  }
}

inbound_allowlist = {
  crest_partner_inbound = {
    consumer_label = "crest-prod-public-api"
    edge_kind      = "front_door"
    address        = "api.crest.example.com"
  }
}

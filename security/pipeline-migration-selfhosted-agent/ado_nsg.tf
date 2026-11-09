locals {
  ado_nsg_rules = merge(
    {
      "ado/out/AzureDevOps/443" = {
        direction                  = "Outbound"
        access                     = "Allow"
        priority                   = 1100
        destination_port_range     = "443"
        destination_address_prefix = "AzureDevOps"
        note                       = "agent registration and job pickup"
      }
      "ado/out/Internet/443" = {
        direction                  = "Outbound"
        access                     = "Allow"
        priority                   = 1110
        destination_port_range     = "443"
        destination_address_prefix = "Internet"
        note                       = "package pulls via NAT"
      }
      "ado/out/Internet/53" = {
        direction                  = "Outbound"
        access                     = "Allow"
        priority                   = 1120
        protocol                   = "Udp"
        destination_port_range     = "53"
        destination_address_prefix = "Internet"
        note                       = "resolution via NAT"
      }
      (local.ado_db_rule_key) = {
        direction                    = "Outbound"
        access                       = "Allow"
        priority                     = 1200
        destination_port_ranges      = var.ado_agent.db_ports
        destination_address_prefixes = var.ado_agent.db_destination_prefixes
        source_address_prefix        = var.ado_agent.address_prefix
        note                         = "pipeline outbound to the DB"
      }
      "ado/out/deny-vnet" = {
        direction                  = "Outbound"
        access                     = "Deny"
        priority                   = 4000
        destination_address_prefix = "VirtualNetwork"
        note                       = "blocks lateral VNet scanning"
      }
      "ado/in/deny-internet" = {
        direction             = "Inbound"
        access                = "Deny"
        priority              = 4000
        source_address_prefix = "Internet"
        note                  = "deny public inbound"
      }
    },
    length(var.ado_agent.hub_pe_destination_prefixes) > 0 ? {
      "ado/out/hub-pe/443" = {
        direction                    = "Outbound"
        access                       = "Allow"
        priority                     = 1250
        destination_port_range       = "443"
        destination_address_prefixes = var.ado_agent.hub_pe_destination_prefixes
        note                         = "optional hub PE"
      }
    } : {},
  )
}

resource "terraform_data" "ado_nsg_rule" {
  for_each = local.ado_nsg_rules

  input = merge(each.value, {
    azure_resource = "azurerm_network_security_rule"
    subnet_name    = var.ado_agent.subnet_name
    rule_key       = each.key
  })
}

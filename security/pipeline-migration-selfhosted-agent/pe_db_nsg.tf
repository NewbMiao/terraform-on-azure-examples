resource "terraform_data" "pe_db_inbound_rule" {
  for_each = local.pe_db_inbound_keys

  input = {
    azure_resource             = "azurerm_network_security_rule"
    subnet_name                = var.pe_db.subnet_name
    rule_key                   = each.key
    direction                  = "Inbound"
    access                     = "Allow"
    priority                   = 200
    source_address_prefix      = each.value
    destination_address_prefix = var.pe_db.address_prefix
    destination_port_range     = "5432"
    note                       = "pe_db inbound 5432"
  }
}

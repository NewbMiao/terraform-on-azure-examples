# Plays: azurerm_private_endpoint.private_service_connection[0].private_ip_address
resource "terraform_data" "private_endpoint" {
  for_each = var.private_link_dns

  input = {
    record_name   = each.value.record_name
    pe_private_ip = each.value.pe_private_ip
  }
}

# Plays: data.azurerm_private_dns_a_record + terraform_data.private_dns_a_record_verify (storage_pe / pg_pe)
resource "terraform_data" "private_dns_a_record_verify" {
  for_each = var.private_link_dns

  lifecycle {
    precondition {
      condition = contains(
        coalesce(each.value.dns_a_records, []),
        each.value.pe_private_ip
      )
      error_message = "Private DNS A record for ${each.value.record_name} in ${each.value.zone_name} is missing or does not match the private endpoint IP ${each.value.pe_private_ip}."
    }
  }

  input = {
    record_name   = each.value.record_name
    zone_name     = each.value.zone_name
    pe_private_ip = each.value.pe_private_ip
    dns_a_records = each.value.dns_a_records
  }

  depends_on = [terraform_data.private_endpoint]
}

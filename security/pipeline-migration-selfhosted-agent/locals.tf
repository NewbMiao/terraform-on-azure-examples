locals {
  ado_db_rule_key = "ado/out/pe_db/${join(",", var.ado_agent.db_ports)}"

  pe_db_inbound_keys = {
    for label, cidr in var.pe_db_inbound_db_sources :
    "pe_db/in/${label}/5432" => cidr
  }

  ado_destinations_cover_pe_db = contains(
    var.ado_agent.db_destination_prefixes,
    var.pe_db.address_prefix,
  )

  pe_db_allows_ado_source = contains(
    values(var.pe_db_inbound_db_sources),
    var.ado_agent.address_prefix,
  )

  pipeline_db_path_ready = local.ado_destinations_cover_pe_db && local.pe_db_allows_ado_source
}

output "ado_nsg_rule_keys" {
  value = sort(keys(terraform_data.ado_nsg_rule))
}

output "pe_db_inbound_rule_keys" {
  value = sort(keys(terraform_data.pe_db_inbound_rule))
}

output "ado_outbound_db" {
  description = "Destination prefixes and ports for the ADO subnet's registered DB egress."
  value       = terraform_data.ado_nsg_rule[local.ado_db_rule_key].input
}

output "pipeline_db_path_ready" {
  description = "Whether the ADO outbound pe_db prefixes and the pe_db inbound ADO source CIDR are paired."
  value       = local.pipeline_db_path_ready
}

output "ado_elastic_pool_name" {
  description = "Use this name for the db_migrate job's pool in the pipeline."
  value       = terraform_data.ado_elastic_pool.input.name
}

output "pairing_gaps" {
  description = "Changing only one side can still leave a clean plan while DB connections time out — the gaps are listed here."
  value = compact([
    !local.ado_destinations_cover_pe_db ? "ado_agent.db_destination_prefixes does not include pe_db.address_prefix" : "",
    !local.pe_db_allows_ado_source ? "pe_db_inbound_db_sources does not include ado_agent.address_prefix" : "",
  ])
}

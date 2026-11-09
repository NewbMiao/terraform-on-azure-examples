locals {
  provider_alias_by_subscription_key = {
    dev  = "azurerm.dev"
    prod = "azurerm.prod"
  }

  team_keys = sort(keys(var.teams))

  ado_team_display_name = {
    for team_key, _ in var.teams :
    team_key => "APP ${title(team_key)} Team"
  }

  # Metadata for the KV-linked variable groups (in production the VG ids are registered in ado_team_library_resources)
  kv_variable_groups = {
    vg_relay_prd_kv = { owner = "relay", kv_name = "kv-relay-prd-sea", scope_rg = "RG-RELAY-PRD-SEA" }
    vg_pulse_prd_kv = { owner = "pulse", kv_name = "kv-pulse-prd-sea", scope_rg = "RG-PULSE-PRD-SEA" }
  }

  shared_variable_group = "vg_shared_templates"
}

# Plays the data listing result: two ACL-mode vaults plus one RBAC-mode vault (skipped).
# access_scopes registers team, dev/prod RGs, and the team SC principal — no vault names.

access_scopes = {
  pulse-dev = {
    team_slug            = "pulse"
    service_principal_id = "dddddddd-1111-4111-8111-111111111111"
    resource_groups = {
      "RG-PULSE-DEV-SEA" = { subscription_key = "dev" }
    }
  }
  pulse-prod = {
    team_slug            = "pulse"
    service_principal_id = "dddddddd-2222-4222-8222-222222222222"
    resource_groups = {
      "RG-PULSE-PRD-SEA" = { subscription_key = "prod" }
    }
  }
}

vault_catalog = {
  "RG-PULSE-DEV-SEA" = {
    resource_group_name = "RG-PULSE-DEV-SEA"
    subscription_key    = "dev"
    vaults = {
      kv-pulse-dev-01 = { rbac_mode = false }
      kv-pulse-dev-02 = { rbac_mode = true }
    }
  }
  "RG-PULSE-PRD-SEA" = {
    resource_group_name = "RG-PULSE-PRD-SEA"
    subscription_key    = "prod"
    vaults = {
      kv-pulse-prd-01 = { rbac_mode = false }
    }
  }
}

team_principal_ids = {
  pulse = "a2222222-2222-4222-8222-222222222202"
}

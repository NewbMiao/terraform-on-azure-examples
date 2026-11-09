team_resource_groups = {
  relay = {
    resource_groups = {
      dev = {
        subscription_key = "dev"
        name             = "RG-RELAY-DEV-SEA"
      }
      prd = {
        subscription_key = "prod"
        name             = "RG-RELAY-PRD-SEA"
      }
    }
  }

  pulse = {
    resource_groups = {
      dev = {
        subscription_key = "dev"
        name             = "RG-PULSE-DEV-SEA"
      }
      prd = {
        subscription_key = "prod"
        name             = "RG-PULSE-PRD-SEA"
      }
    }
  }

  harbor = {
    resource_groups = {
      dev = {
        subscription_key = "dev"
        name             = "RG-HARBOR-DEV-SEA"
      }
      prd = {
        subscription_key = "prod"
        name             = "RG-HARBOR-PRD-SEA"
      }
    }
  }
}

# Write actions registered per team: KV / ACA / PG are the three kinds the shared account touched most
deny_assignments = {
  shared_deploy_relay_prd = {
    subscription_key     = "prod"
    resource_group_name  = "RG-RELAY-PRD-SEA"
    deny_assignment_name = "deny-shared-deploy-relay-prd"
    users                = ["shared-deploy"]
    actions = [
      "Microsoft.KeyVault/vaults/write",
      "Microsoft.App/containerApps/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/write",
    ]
    phase = "prod-deny"
  }

  shared_deploy_pulse_prd = {
    subscription_key     = "prod"
    resource_group_name  = "RG-PULSE-PRD-SEA"
    deny_assignment_name = "deny-shared-deploy-pulse-prd"
    users                = ["shared-deploy"]
    actions = [
      "Microsoft.KeyVault/vaults/write",
      "Microsoft.App/containerApps/write",
    ]
    phase = "prod-deny"
  }

  shared_deploy_harbor_prd = {
    subscription_key     = "prod"
    resource_group_name  = "RG-HARBOR-PRD-SEA"
    deny_assignment_name = "deny-shared-deploy-harbor-prd"
    users                = ["shared-deploy"]
    actions = [
      "Microsoft.App/containerApps/write",
      "Microsoft.Storage/storageAccounts/write",
    ]
    phase = "prod-deny"
  }

  # The three dev entries are registered but wait for phase 4
  shared_deploy_relay_dev = {
    subscription_key     = "dev"
    resource_group_name  = "RG-RELAY-DEV-SEA"
    deny_assignment_name = "deny-shared-deploy-relay-dev"
    users                = ["shared-deploy"]
    actions = [
      "Microsoft.KeyVault/vaults/write",
      "Microsoft.App/containerApps/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/write",
    ]
    phase = "dev-deny"
  }

  shared_deploy_pulse_dev = {
    subscription_key     = "dev"
    resource_group_name  = "RG-PULSE-DEV-SEA"
    deny_assignment_name = "deny-shared-deploy-pulse-dev"
    users                = ["shared-deploy"]
    actions = [
      "Microsoft.KeyVault/vaults/write",
      "Microsoft.App/containerApps/write",
    ]
    phase = "dev-deny"
  }

  shared_deploy_harbor_dev = {
    subscription_key     = "dev"
    resource_group_name  = "RG-HARBOR-DEV-SEA"
    deny_assignment_name = "deny-shared-deploy-harbor-dev"
    users                = ["shared-deploy"]
    actions = [
      "Microsoft.App/containerApps/write",
      "Microsoft.Storage/storageAccounts/write",
    ]
    phase = "dev-deny"
  }
}

# Phase 3: prod goes first, observe for at least a week or two
active_phases = ["prod-deny"]

teams = {
  relay = {
    security_group = { display_name = "SGRP-RELAY" }
    members        = ["alice.relay", "carol.platform"]

    # prod: Reader + Operator baseline (no Contributor / Container Apps Contributor)
    prod_resource_groups = {
      relay_prd_sea = {
        subscription_key = "prod"
        roles = [
          "Reader",
          "Monitoring Reader",
          "Storage Blob Data Reader",
          "Container Apps Operator",
          "Container Apps Jobs Operator",
        ]
      }
    }
    dev_resource_groups = {
      relay_dev_sea = {
        subscription_key = "dev"
        roles = [
          "Reader",
          "Monitoring Reader",
          "Container Apps Contributor",
          "Container Apps Jobs Contributor",
          "Key Vault Contributor",
          "Key Vault Secrets Officer",
          "Storage Account Contributor",
        ]
      }
    }
    resource_access = {
      pg_dev = {
        subscription_key    = "dev"
        resource_group_name = "RG-RELAY-DEV-SEA"
        resource_name       = "pg-relay-dev-sea"
        resource_type       = "Microsoft.DBforPostgreSQL/flexibleServers"
        roles               = ["Contributor"]
        environments        = ["dev"]
      }
      foundry_dev = {
        subscription_key    = "dev"
        resource_group_name = "RG-RELAY-DEV-SEA"
        resource_name       = "aif-relay-dev-sea"
        resource_type       = "Microsoft.CognitiveServices/accounts"
        roles               = ["Foundry Owner"]
        environments        = ["dev"]
      }
      foundry_prod = {
        subscription_key    = "prod"
        resource_group_name = "RG-RELAY-PRD-SEA"
        resource_name       = "aif-relay-prd-sea"
        resource_type       = "Microsoft.CognitiveServices/accounts"
        roles               = ["Foundry User"]
        environments        = ["prod"]
      }
    }
  }

  pulse = {
    security_group = { display_name = "SGRP-PULSE" }
    members        = ["bob.pulse"]

    prod_resource_groups = {
      pulse_prd_sea = {
        subscription_key = "prod"
        roles = [
          "Reader",
          "Monitoring Reader",
          "Container Apps Operator",
        ]
      }
    }
    dev_resource_groups = {
      pulse_dev_sea = {
        subscription_key = "dev"
        roles = [
          "Reader",
          "Monitoring Reader",
          "Container Apps Contributor",
          "Key Vault Secrets Officer",
        ]
      }
    }
  }

  harbor = {
    security_group = { display_name = "SGRP-HARBOR" }
    members        = ["dana.harbor", "carol.platform"]

    prod_resource_groups = {
      harbor_prd_sea = {
        subscription_key = "prod"
        roles = [
          "Reader",
          "Monitoring Reader",
          "Container Apps Operator",
        ]
      }
    }
    dev_resource_groups = {
      harbor_dev_sea = {
        subscription_key = "dev"
        roles = [
          "Reader",
          "Monitoring Reader",
          "Container Apps Contributor",
        ]
      }
    }
  }
}

# Platform ACR — shared team access; repository-level isolation is configured separately.
shared_resource_access = {
  org_acr = {
    subscription_key    = "prod"
    resource_group_name = "RG-EG-HUB-INF"
    resource_name       = "acreg"
    resource_type       = "Microsoft.ContainerRegistry/registries"
    roles               = ["Reader"]
    teams               = ["relay", "pulse", "harbor"]
  }
}

# Scope tokens: path-scoped pull/push without switching the registry to ABAC mode.
acr_scope_tokens = {
  org_acr = {
    registry_name = "acreg"
    paths = {
      "relay/"  = { team_key = "relay", token = "pull" }
      "pulse/"  = { team_key = "pulse", token = "pull" }
      "harbor/" = { team_key = "harbor", token = "pull" }
    }
  }
}

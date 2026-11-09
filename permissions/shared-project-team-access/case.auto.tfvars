# teams (Azure) + team_ado (ADO allowlist); under library: VG/Environment name → ADO numeric id
project = { name = "APP" }

teams = {
  relay = {
    security_group = { display_name = "SGRP-RELAY", object_id = "a1111111-1111-4111-8111-111111111101" }
    resource_groups = {
      dev = { subscription_key = "dev", name = "RG-RELAY-DEV-SEA" }
      prd = { subscription_key = "prod", name = "RG-RELAY-PRD-SEA" }
    }
  }
  pulse = {
    security_group = { display_name = "SGRP-PULSE", object_id = "a2222222-2222-4222-8222-222222222202" }
    resource_groups = {
      dev = { subscription_key = "dev", name = "RG-PULSE-DEV-SEA" }
      prd = { subscription_key = "prod", name = "RG-PULSE-PRD-SEA" }
    }
  }
  harbor = {
    security_group = { display_name = "SGRP-HARBOR", object_id = "a3333333-3333-4333-8333-333333333303" }
    resource_groups = {
      dev = { subscription_key = "dev", name = "RG-HARBOR-DEV-SEA" }
      prd = { subscription_key = "prod", name = "RG-HARBOR-PRD-SEA" }
    }
  }
}

team_ado = {
  relay = {
    service_connection_names = ["sc-relay-dev", "sc-relay-prd", "sc-relay-acr"]
    pipeline_path            = "\\relay"
    git_repositories = {
      relay-app = {}
    }
    library = {
      variable_groups = {
        vg_relay_prd_kv     = 101
        vg_shared_templates = 102
      }
      environments = { "relay-uat" = 49, "relay-prod" = 53 }
    }
  }
  pulse = {
    service_connection_names = ["sc-pulse-dev", "sc-pulse-prd", "sc-pulse-acr"]
    pipeline_path            = "\\pulse"
    git_repositories = {
      pulse-app = {}
    }
    library = {
      variable_groups = {
        vg_pulse_prd_kv     = 110
        vg_shared_templates = 102
      }
      environments = { "pulse-uat" = 50, "pulse-prod" = 54 }
    }
  }
  harbor = {
    service_connection_names = ["sc-harbor-dev", "sc-harbor-prd", "sc-harbor-acr"]
    pipeline_path            = "\\harbor"
    git_repositories = {
      harbor-app = {}
    }
    library = {
      variable_groups = { vg_shared_templates = 102 }
      environments    = {}
    }
  }
}

# Contrast: the lesson's "Comparison" section — two subscription-scoped connections (delete the whole block after switching to team SCs)
legacy_subscription_service_connections = {
  dev = {
    name             = "sc-shared-dev"
    subscription_key = "dev"
    deploy_identity  = "wi-shared-deploy"
  }
  prd = {
    name             = "sc-shared-prd"
    subscription_key = "prod"
    deploy_identity  = "wi-shared-deploy"
  }
}

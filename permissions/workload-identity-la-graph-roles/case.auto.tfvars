graph_api = {
  service_principal_object_id = "dddddddd-dddd-4ddd-8ddd-dddddddddddd"
  app_roles = {
    "Sites.Selected"                    = "eeeeeeee-eeee-4eee-8eee-eeeeeeeeeee1"
    "Files.SelectedOperations.Selected" = "eeeeeeee-eeee-4eee-8eee-eeeeeeeeeee2"
  }
}

workloads = {
  pulse-km-dev = {
    team_key                      = "pulse"
    environment                   = "dev"
    display_name                  = "la-pulse-km-sync-dev"
    resource_group_name           = "RG-PULSE-DEV-SEA"
    location                      = "southeastasia"
    managed_identity_principal_id = "bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb"
    graph_roles = [
      "Sites.Selected",
      "Files.SelectedOperations.Selected",
    ]
    use_managed_identity_for_graph = true
  }
}

# Set enabled = true to plan the legacy contrast block (still no secret in plaintext)
legacy_entra_apps = {
  pulse-km-legacy = {
    display_name          = "pulse-km-sync"
    team_key              = "pulse"
    environment           = "dev"
    key_vault_secret_name = "pulse-km-client-secret"
    graph_roles           = ["Sites.Selected"]
    enabled               = false
  }
}

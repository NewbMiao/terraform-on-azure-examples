workbook = {
  display_name     = "pulse AKS request sizing (LGW)"
  lgw_workspace_id = "/subscriptions/00000000-0000-0000-0000-00000000a101/resourcegroups/RG-PULSE-PROD-EA/providers/microsoft.operationalinsights/workspaces/lgw-pulse-prod-ea"
  resource_group   = "RG-PULSE-PROD-EA"
  location         = "australiaeast"

  cluster_options = [
    { value = "aks-pulse-prod-ea", label = "PROD" },
    { value = "aks-pulse-uat-ea", label = "UAT" },
  ]
  cluster_default = "aks-pulse-prod-ea"

  namespace_options = [
    { value = "pulse-agent", label = "pulse-agent" },
    { value = "pulse-app", label = "pulse-app" },
  ]
  namespace_default = ["pulse-agent", "pulse-app"]
}

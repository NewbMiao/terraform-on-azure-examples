# Contrast (before the switch): the whole project has only one ARM service connection each for dev / prod, scoped to the full subscription, shared by all three teams' pipelines.
# Read side by side with the team-scoped sc-{team}-{env} @ RG in service_connections.tf; after switching to team SCs, delete this file and the legacy_* block in tfvars.

resource "terraform_data" "legacy_subscription_service_connection" {
  for_each = var.legacy_subscription_service_connections

  input = {
    azure_resource        = "azuredevops_serviceendpoint_azurerm"
    service_endpoint_name = each.value.name
    auth_scheme           = "WorkloadIdentityFederation"
    deploy_identity       = each.value.deploy_identity
    subscription_key      = each.value.subscription_key
    subscription_label    = var.subscriptions[each.value.subscription_key].display_name
    scope_kind            = "subscription"
    rbac_note             = "Contributor on full subscription — KV picker lists every team vault"
  }
}

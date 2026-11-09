resource "terraform_data" "dns_identity" {
  # Azure resource: azurerm_user_assigned_identity (the identity the issuer uses to write DNS)
  count = var.cert_manager.enabled ? 1 : 0

  input = {
    name                = var.cert_manager.managed_identity
    resource_group_name = var.tls.dns.resource_group_name
    federated_credential = {
      issuer  = "aks-oidc-issuer/${var.cluster.name}"
      subject = "system:serviceaccount:${var.cert_manager.service_account.namespace}:${var.cert_manager.service_account.name}"
    }
  }
}

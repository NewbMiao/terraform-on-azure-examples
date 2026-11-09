resource "terraform_data" "cluster_issuer" {
  # Kubernetes resource: cert-manager.io/v1 ClusterIssuer (handled by the Helm-installed controller)
  count = var.cert_manager.enabled ? 1 : 0

  input = {
    name        = var.cert_manager.issuer_name
    acme_server = var.cert_manager.acme_server
    account_key = "le-account-key"
    # One solver per child zone: a solver can only point at a single hostedZone
    solvers = [for zone in local.env_zones : {
      dns_zones = [zone]
      azure_dns = {
        subscription_id     = var.tls.dns.subscription_id
        resource_group_name = var.tls.dns.resource_group_name
        hosted_zone_name    = zone
        managed_identity    = var.cert_manager.managed_identity
      }
    }]
  }

  depends_on = [terraform_data.dns_zone_grant]
}

resource "terraform_data" "certificate" {
  # Kubernetes resource: cert-manager.io/v1 Certificate (one per environment)
  for_each = var.cert_manager.enabled ? local.environment_certificates : {}

  input = {
    name       = each.value.certificate
    namespace  = var.cluster.namespace
    secretName = each.value.secret_name # matches the tls.secretName of that environment's Ingress
    dnsNames   = [each.value.hostname]
    zone       = each.value.zone
    issuerRef = {
      kind = "ClusterIssuer"
      name = var.cert_manager.issuer_name
    }
    renewal = "auto-triggered by the issuer based on remaining lifetime"
  }

  depends_on = [terraform_data.cluster_issuer]
}

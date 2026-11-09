output "secret" {
  value = {
    for name, cert in local.environment_certificates : name => {
      name      = cert.secret_name
      namespace = var.cluster.namespace
      host      = cert.hostname
      zone      = cert.zone
      owner     = local.secret_owner
      issuer    = var.cert_manager.enabled ? var.cert_manager.issuer_name : null
    }
  }
}

output "dns" {
  value = {
    for zone, layout in local.zone_layout : zone => {
      delegation = terraform_data.dns_delegation[zone].input
      grant      = var.cert_manager.enabled ? terraform_data.dns_zone_grant[zone].input : null
    }
  }
}

output "cert_manager" {
  value = var.cert_manager.enabled ? {
    issuer       = terraform_data.cluster_issuer[0].input
    certificates = { for name, cert in terraform_data.certificate : name => cert.input }
    identity     = terraform_data.dns_identity[0].input
  } : null
}

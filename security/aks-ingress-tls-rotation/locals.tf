locals {
  # A Secret can only have one writer: with both paths enabled, the later write overwrites the earlier one
  secret_writers = compact([
    var.legacy_kv_csi.enabled ? "secrets-store-csi" : "",
    var.cert_manager.enabled ? "cert-manager" : "",
  ])

  secret_owner = length(local.secret_writers) == 1 ? local.secret_writers[0] : "conflict"

  # One child zone can be shared by multiple environments; for per-environment isolation, give each a different zone in tfvars
  env_zones = distinct([for name, env in var.environments : env.zone])

  zone_layout = {
    for zone in local.env_zones : zone => {
      delegation_label = split(".", zone)[0] # crest.example.com → crest under the parent zone
      parent_zone      = var.tls.dns.parent_zone
      environments     = [for name, env in var.environments : name if env.zone == zone]
    }
  }

  environment_certificates = {
    for name, env in var.environments : name => {
      certificate = env.certificate
      hostname    = env.hostname
      zone        = env.zone
      secret_name = "${var.tls.secret_name}-${name}"
    }
  }
}

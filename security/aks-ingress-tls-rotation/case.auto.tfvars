cluster = {
  name          = "aks-crest-dev-sea"
  namespace     = "ingress-nginx"
  ingress_class = "nginx"
}

tls = {
  secret_name = "crest-tls"
  dns = {
    parent_zone         = "example.com"
    child_zone          = "crest.example.com"
    resource_group_name = "RG-EG-DNS"
    subscription_id     = "00000000-0000-0000-0000-00000000d005"
  }
}

# One team, two hostnames in a single child zone: the TXT records all land in crest.example.com.
# If dev's DNS permissions also need isolation, change the zone to dev.crest.example.com and delegate it separately.
environments = {
  dev = {
    hostname    = "api-dev.crest.example.com"
    certificate = "crest-tls-dev"
    zone        = "crest.example.com"
  }
  prod = {
    hostname    = "api.crest.example.com"
    certificate = "crest-tls-prod"
    zone        = "crest.example.com"
  }
}

# Cutover period: the old objects still run in the cluster, so set legacy_kv_csi.enabled to true
# to mark the Secret as owned by the old path; once the cert-manager Certificate is ready and the
# Secret contents are confirmed switched over, flip it to false and delete the old objects under k8s/.
legacy_kv_csi = {
  enabled = false
}

cert_manager = {
  enabled          = true
  issuer_name      = "letsencrypt-dns01"
  acme_server      = "https://acme-v02.api.letsencrypt.org/directory"
  managed_identity = "id-crest-cert-manager-dns"
  service_account = {
    namespace = "cert-manager"
    name      = "cert-manager"
  }
}

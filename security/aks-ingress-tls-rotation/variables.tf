variable "cluster" {
  type = object({
    name          = string
    namespace     = string
    ingress_class = string
  })
  description = "The cluster hosting the internal Ingress controller; TLS lands in the ingress-nginx namespace."
}

variable "tls" {
  type = object({
    secret_name = string
    dns = object({
      parent_zone         = string
      child_zone          = string
      resource_group_name = string
      subscription_id     = string
    })
  })
  description = "The Ingress Secret name and DNS delegation: the child zone sits under the parent zone, and the issuer writes only in the child zone."
}

variable "environments" {
  type = map(object({
    hostname    = string
    certificate = string
    zone        = string
  }))
  description = "Hostnames and Certificates split by environment; zones may all point at the same child zone or each get its own."
}

variable "legacy_kv_csi" {
  type = object({
    enabled = bool
  })
  description = "Switch for the old path, used only during cutover to block one of the two Secret-writing routes; the cluster-side objects live under k8s/retired/."
}

variable "cert_manager" {
  type = object({
    enabled          = bool
    issuer_name      = string
    acme_server      = string
    managed_identity = string
    service_account = object({
      namespace = string
      name      = string
    })
  })
  description = "The new path: cert-manager issues and renews on its own; private origins use DNS-01."
}

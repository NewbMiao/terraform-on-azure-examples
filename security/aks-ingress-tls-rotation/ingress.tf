resource "terraform_data" "ingress" {
  # Kubernetes resource: networking.k8s.io/v1 Ingress (one per environment)
  for_each = local.environment_certificates

  input = {
    name               = "crest-api-${each.key}"
    namespace          = var.cluster.namespace
    ingress_class_name = var.cluster.ingress_class
    host               = each.value.hostname
    tls = {
      hosts       = [each.value.hostname]
      secret_name = each.value.secret_name # neither path changes this line
    }
    backend = "crest-api:80"
  }

  lifecycle {
    precondition {
      condition     = length(local.secret_writers) <= 1
      error_message = "A Secret can only have one writer: legacy_kv_csi and cert_manager must not both be enabled."
    }

    precondition {
      condition     = length(local.secret_writers) >= 1
      error_message = "There must be at least one writer: enable legacy_kv_csi or cert_manager, otherwise the Ingress gets no Secret."
    }
  }
}

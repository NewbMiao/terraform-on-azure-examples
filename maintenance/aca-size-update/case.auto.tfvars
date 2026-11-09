# Simulates what data.azapi_resource.live currently reads (the pipeline has already released).
live = {
  image             = "registry.example/app:2026.10.08"
  env               = ["LOG_LEVEL=info", "FEATURE_X=true"]
  secret_names      = ["database-password"]
  probes            = ["https://app/health"]
  cpu               = 0.5
  memory            = "1Gi"
  ephemeral_storage = "2Gi"
}

# Terraform-owned sizing (same names as the real aca_app variables).
template_cpu    = 1
template_memory = "2Gi"
min_replicas    = 3
max_replicas    = 20

# Mounts owned by this layer: they enter the fingerprint and the PATCH's volumes / volumeMounts.
volume_mounts = [
  {
    name         = "app-data"
    mount_path   = "/data"
    storage_name = "stegdevacaappdata"
  },
]

locals {
  # --- Mirrors data.azapi_resource.live → template_live_container ---
  template_live_container = {
    name         = "app"
    image        = var.live.image
    env          = var.live.env
    secret_names = var.live.secret_names
    probes       = var.live.probes
    resources = {
      cpu               = var.live.cpu
      memory            = var.live.memory
      ephemeral_storage = var.live.ephemeral_storage
    }
  }

  # --- Mirrors template_volumes / template_volume_mounts: mounts owned by this layer ---
  volume_defs = { for m in var.volume_mounts : m.name => m... }

  template_volumes = [
    for name, defs in local.volume_defs : {
      name        = name
      storageType = defs[0].storage_type
      storageName = defs[0].storage_name
    }
  ]

  template_volume_mounts = [
    for m in var.volume_mounts : {
      volumeName = m.name
      mountPath  = m.mount_path
    }
  ]

  # --- Mirrors volumes_fingerprint_suffix / sizing_trigger_fingerprint ---
  # The fingerprint tracks what this layer owns: size + mounts; image / env / secret stay outside.
  volumes_fingerprint_suffix = length(var.volume_mounts) > 0 ? ":${md5(jsonencode(var.volume_mounts))}" : ""

  sizing_trigger_fingerprint = md5(format("%v:%v:%v:%v%s",
    var.template_cpu,
    var.template_memory,
    var.min_replicas,
    var.max_replicas,
    local.volumes_fingerprint_suffix,
  ))
}

# --- Mirrors terraform_data.sizing ---
resource "terraform_data" "sizing" {
  input = local.sizing_trigger_fingerprint
}

locals {
  # Every action rebuild needs a fresh one; truncating just the fingerprint collides with the previous round and the server won't mint a new revision.
  revision_suffix = substr(md5(format("%s:%s", local.sizing_trigger_fingerprint, plantimestamp())), 0, 12)

  # --- Mirrors patch_properties / template_patch_body: live ⊕ size ---
  # containers is an array — supplying it replaces the whole block, so container rows must be carried back in full;
  # merge is shallow: resources needs its own nested merge, or the remote ephemeral_storage gets wiped.
  volumes_enabled = length(var.volume_mounts) > 0

  template_container_patch_overrides = merge(
    {},
    local.volumes_enabled ? { volumeMounts = local.template_volume_mounts } : {},
  )

  template_patch_body = merge(
    {
      revisionSuffix = local.revision_suffix
      scale = {
        minReplicas = var.min_replicas
        maxReplicas = var.max_replicas
      }
      containers = [
        merge(
          local.template_live_container,
          {
            resources = merge(
              local.template_live_container.resources,
              {
                cpu    = var.template_cpu
                memory = var.template_memory
              },
            )
          },
          local.template_container_patch_overrides,
        )
      ]
    },
    # volumes also belong to this layer; when there are no mounts, omit the block entirely rather than sending an empty array.
    local.volumes_enabled ? { volumes = local.template_volumes } : {},
  )

  patch_properties = {
    template = local.template_patch_body
    # Switch traffic after the new revision exists; the pipeline may have pinned traffic to the old one.
    configuration = {
      ingress = {
        traffic = [{ latestRevision = true, weight = 100 }]
      }
    }
  }
}

# --- Mirrors azapi_resource_action.template ---
# input ≈ body; ignore_changes ≈ ignore body; replace_triggered_by ≈ sizing
resource "terraform_data" "template" {
  input = jsonencode(local.patch_properties)

  lifecycle {
    ignore_changes       = [input]
    replace_triggered_by = [terraform_data.sizing]

    precondition {
      condition     = try(local.template_live_container.image, null) != null
      error_message = "The remote template has no container image; release first, then resize."
    }
  }
}

output "patch_properties" {
  description = "The currently computed live⊕size (the body the next size apply will write)."
  value       = local.patch_properties
}

output "applied_template" {
  description = "The PATCH body the last size apply wrote into state."
  value       = jsondecode(terraform_data.template.output)
}

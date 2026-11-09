module "aca" {
  source = "./modules/aca"

  live            = var.live
  template_cpu    = var.template_cpu
  template_memory = var.template_memory
  min_replicas    = var.min_replicas
  max_replicas    = var.max_replicas
  volume_mounts   = var.volume_mounts
}

# Only exports the already-applied template action body, avoiding output-only plan noise when just live.image changes.
output "applied_template" {
  value = module.aca.applied_template
}

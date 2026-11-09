workloads = {
  relay_api = {
    name        = "aca-eg-dev-relay-api"
    environment = "dev"
    sku         = "consumption"
    replicas    = 2
    tags = {
      team = "relay"
    }
  }

  pulse_worker = {
    name        = "aca-eg-prod-pulse-worker"
    environment = "prod"
    sku         = "dedicated-d4"
    replicas    = 3
    tags = {
      team        = "pulse"
      cost_center = "platform"
    }
  }
}

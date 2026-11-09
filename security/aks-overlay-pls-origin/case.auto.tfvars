cluster = {
  name             = "aks-crest-dev-sea"
  node_subnet_name = "snet-eg-aks-crest-dev"
  node_subnet_cidr = "172.20.64.0/27" # nodes take shared-VNet addresses; /27 is enough under overlay
  pod_cidr         = "192.168.0.0/16" # separate Pod range, no overlap with the VNet
  node_count       = 3
}

nsg_edges = {
  pe_db_cidr = "172.20.96.0/27"
  db_port    = 5432
  nat_egress = true
}

pls = {
  name         = "pls-crest-ingress-internal-dev"
  request_note = "org-afd-crest-dev-aks"
}

waf = {
  profile         = "edge-dev"
  public_hostname = "crest.example.com"
}

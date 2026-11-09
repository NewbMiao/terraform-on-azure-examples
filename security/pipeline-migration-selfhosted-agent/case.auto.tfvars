ado_agent = {
  subnet_name             = "SNET-EG-DEV-ADO"
  address_prefix          = "172.20.3.240/28"
  db_destination_prefixes = ["172.20.0.128/27"]
  db_ports                = ["5432"]
}

pe_db = {
  subnet_name    = "SNET-EG-DEV-PE-DB"
  address_prefix = "172.20.0.128/27"
}

pe_db_inbound_db_sources = {
  aca_relay = "172.20.0.0/26"
  ado_dev   = "172.20.3.240/28"
}

ado_elastic_pool = {
  name                  = "vmss-eg-agents-dev-sea"
  vmss_name             = "vmss-eg-agents-dev-sea"
  service_endpoint_name = "sc-eg-dev-arm-wif"
  desired_idle          = 0
  max_capacity          = 3
}

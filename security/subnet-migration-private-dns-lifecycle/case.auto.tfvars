private_link_dns = {
  stpulseprd_blob = {
    record_name   = "stpulseprd"
    zone_name     = "privatelink.blob.core.windows.net"
    pe_private_ip = "172.21.0.68"
    dns_a_records = ["172.21.0.68"]
  }
  relay_pg_dev = {
    record_name   = "relay-pg-dev-sea"
    zone_name     = "privatelink.postgres.database.azure.com"
    pe_private_ip = "172.20.0.132"
    dns_a_records = ["172.20.0.132"]
  }
}

storage_pe = {
  stpulseprd_blob = {
    environment            = "prod"
    account_name           = "stpulseprd"
    account_resource_group = "RG-PULSE-PRD-SEA"
    subresource_names      = ["blob"]
    network = {
      resource_group_name = "RG-EG-PROD-NET-SEA"
      vnet_name           = "VNET-EG-PROD-SEA-01"
      subnet_name         = "SNET-EG-PROD-PE"
    }
    private_dns = {
      zone_name                = "privatelink.blob.core.windows.net"
      zone_resource_group_name = "RG-EG-PROD-NET-SEA"
      create_zone              = false
      verify_a_record          = true
      vnet_links = [{
        name                     = "link-prod-sea-eg-01-blob"
        vnet_resource_group_name = "RG-EG-PROD-NET-SEA"
        vnet_name                = "VNET-EG-PROD-SEA-01"
      }]
    }
  }
}

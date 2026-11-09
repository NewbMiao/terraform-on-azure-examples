tenants = {
  pulse = {
    tenant_id    = "11111111-1111-4111-8111-111111111111"
    email_domain = "example.org"
  }
}

applications = {
  relay_group_portal = {
    display_name        = "relay-group-portal"
    redirect_uris       = ["https://portal.relay.example.com/auth/callback"]
    sign_in_audience    = "AzureADMultipleOrgs"
    allowed_tenant_keys = ["pulse"]
    patch_restrictions  = true
  }

  relay_admin_portal = {
    display_name  = "relay-admin-portal"
    redirect_uris = ["https://admin.relay.example.com/auth/callback"]
  }
}

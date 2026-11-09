locals {
  # The example uses stable UUIDs to play the object ids of the existing azuread_application.
  application_object_ids = {
    for key, app in var.applications :
    key => uuidv5("url", "https://example.com/applications/${key}")
  }

  audience_patch_apps = {
    for key, app in var.applications : key => app
    if app.patch_restrictions
  }

  audience_patch_requests = {
    for key, app in local.audience_patch_apps : key => {
      url           = "applications/${local.application_object_ids[key]}"
      api_version   = "beta"
      update_method = "PATCH"
      body = {
        signInAudience = app.sign_in_audience
        signInAudienceRestrictions = {
          "@odata.type" = "#microsoft.graph.allowedTenantsAudience"
          kind          = "allowedTenants"
          allowedTenantIds = [
            for tenant_key in app.allowed_tenant_keys :
            var.tenants[tenant_key].tenant_id
          ]
          isHomeTenantAllowed = true
        }
      }
    }
  }
}

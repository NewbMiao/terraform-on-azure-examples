# Plays azurerm_api_management_api — the platform owns the OpenAPI import
resource "terraform_data" "apim_api_platform" {
  for_each = local.app_http_apis_platform

  input = {
    # Maps to Microsoft.ApiManagement/service/apis
    name             = each.key
    path             = each.value.path
    openapi_file     = each.value.openapi_file
    lifecycle_ignore = ["description"]
    import_managed   = true
  }
}

# Plays azurerm_api_management_api.app_portal — Portal is the SSOT
resource "terraform_data" "apim_api_portal" {
  for_each = local.app_http_apis_portal

  input = {
    name             = each.key
    path             = each.value.path
    openapi_file     = each.value.openapi_file
    lifecycle_ignore = ["description", "import"]
    import_managed   = true
  }
}

# Plays azurerm_api_management_api_policy.app_portal
resource "terraform_data" "apim_api_policy_portal" {
  for_each = local.app_http_apis_portal

  input = {
    api_name         = each.key
    lifecycle_ignore = ["xml_content"]
  }
}

# Plays azapi_resource hub_backend / hub_backend_portal
resource "terraform_data" "apim_backend" {
  for_each = {
    for name, cfg in var.app_apis : cfg.backend_id => cfg
  }

  input = {
    # Maps to Microsoft.ApiManagement/service/backends
    name             = each.key
    lifecycle_ignore = contains(local.app_portal_managed_backend_ids, each.key) ? ["body"] : []
  }
}

# Plays azurerm_api_management_product_api — no ignores; driven by the sheet
resource "terraform_data" "apim_product_api" {
  for_each = local.app_product_apis

  input = {
    # Maps to …/products/{product}/apis/{api}
    product_id       = each.value.product_id
    api_name         = each.value.api_name
    lifecycle_ignore = []
    note             = "Portal products/apis/delete → update app_products, don't ignore"
  }
}

# Plays azurerm_role_assignment @ child scope
resource "terraform_data" "apim_scoped_assignment" {
  for_each = local.apim_scoped_assignments

  input = {
    scope = each.value.scope
    team  = each.value.team
    user  = each.value.user
  }
}

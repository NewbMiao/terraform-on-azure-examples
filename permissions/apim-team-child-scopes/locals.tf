locals {
  app_http_apis = var.app_apis

  app_http_apis_platform = {
    for name, cfg in local.app_http_apis : name => cfg
    if !coalesce(cfg.portal_managed, false)
  }

  app_http_apis_portal = {
    for name, cfg in local.app_http_apis : name => cfg
    if coalesce(cfg.portal_managed, false)
  }

  app_portal_managed_backend_ids = toset([
    for _, cfg in local.app_http_apis : cfg.backend_id if coalesce(cfg.portal_managed, false)
  ])

  app_product_apis = {
    for pair in flatten([
      for product_id, product in var.app_products : [
        for api_name in product.api_names : {
          key        = "${product_id}/${api_name}"
          product_id = product_id
          api_name   = api_name
        }
      ]
    ]) : pair.key => pair
  }

  apim_resource_segments = {
    api          = "apis"
    backend      = "backends"
    product      = "products"
    subscription = "subscriptions"
    namedvalue   = "namedValues"
  }

  apim_scoped_assignments = {
    for row in flatten([
      for team_key, row in var.apim_api_access : [
        for user in coalesce(row.users, []) : [
          for kind, segment in local.apim_resource_segments : [
            for name in coalesce(
              kind == "api" ? row.api_names :
              kind == "backend" ? row.backend_names :
              kind == "product" ? row.product_names :
              kind == "subscription" ? row.subscription_names :
              row.named_value_names,
              []
              ) : {
              key   = "${team_key}/${user}/${kind}/${name}"
              scope = "${var.apim_service_id}/${segment}/${name}"
              user  = user
              team  = team_key
            }
          ]
        ]
      ]
    ]) : row.key => row
  }
}

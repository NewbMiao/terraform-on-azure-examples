output "portal_managed_api_ignore" {
  description = "Portal-SSOT APIs: apply does not overwrite the OpenAPI import / API policy."
  value = {
    for k, v in terraform_data.apim_api_portal : k => v.input.lifecycle_ignore
  }
}

output "product_api_keys" {
  description = "Product↔API keys expanded from the platform app_products; a missing entry shows +create in plan — so does a Portal unlink not yet reflected in the sheet."
  value       = keys(terraform_data.apim_product_api)
}

output "scoped_assignment_count" {
  value = length(terraform_data.apim_scoped_assignment)
}

output "backend_body_ignore" {
  value = {
    for k, v in terraform_data.apim_backend : k => v.input.lifecycle_ignore
  }
}

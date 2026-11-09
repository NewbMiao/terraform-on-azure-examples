output "application_object_ids" {
  description = "Application object ids maintained by the publisher; no second mirror App should appear for pulse."
  value       = local.application_object_ids
}

output "audience_patch_requests" {
  description = "The PATCH request shapes generated against the existing application objects."
  value       = local.audience_patch_requests
}

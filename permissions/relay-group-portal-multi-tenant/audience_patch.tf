# Plays the real msgraph_update_resource: PATCH against the existing application object.
resource "terraform_data" "audience_restrictions_patch" {
  for_each = local.audience_patch_requests

  input = each.value

  lifecycle {
    precondition {
      condition     = var.applications[each.key].sign_in_audience == "AzureADMultipleOrgs"
      error_message = "${each.key}: tenant allow-list requires sign_in_audience = AzureADMultipleOrgs."
    }
  }

  depends_on = [terraform_data.application_registration]
}

# The wrong way: msgraph_resource would POST to /applications, creating a second App registration.
# resource "msgraph_resource" "pulse_duplicate_app" {
#   url         = "applications"
#   api_version = "v1.0"
#
#   body = {
#     displayName    = "relay-group-portal-pulse-mirror"
#     signInAudience = "AzureADMultipleOrgs"
#   }
# }

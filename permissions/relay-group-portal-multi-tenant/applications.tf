# Plays the real azuread_application: the publisher maintains a single app registration.
resource "terraform_data" "application_registration" {
  for_each = var.applications

  input = {
    object_id        = local.application_object_ids[each.key]
    display_name     = each.value.display_name
    sign_in_audience = each.value.sign_in_audience
    redirect_uris    = each.value.redirect_uris
  }
}

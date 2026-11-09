# Plays the azuread_application_password instance after state injection, fields matching the provider.
locals {
  adopted_password = {
    application_id = "/applications/${var.app.object_id}"
    key_id         = var.portal_credential.key_id
    display_name   = var.portal_credential.display_name
    start_date     = var.portal_credential.start_date
    end_date       = var.portal_credential.end_date
    value          = var.client_secret
  }

  # Only metadata is exposed: plaintext goes to neither outputs nor logs.
  credential_metadata = {
    key_id       = local.adopted_password.key_id
    display_name = local.adopted_password.display_name
    end_date     = local.adopted_password.end_date
  }
}

locals {
  email_enabled = local.enabled && try(local.report.email.enabled, false)
}

resource "terraform_data" "monthly_cost_report_email_sender" {
  count = local.email_enabled ? 1 : 0

  input = {
    name  = "MonthlyCostReportEmailSender"
    value = local.report.email.sender
  }
}

resource "terraform_data" "monthly_cost_report_email_recipients" {
  count = local.email_enabled ? 1 : 0

  input = {
    name  = "MonthlyCostReportEmailRecipients"
    value = local.report.email.recipients
  }
}

# Plays azuread_app_role_assignment — Graph Mail.Send
resource "terraform_data" "report_mail_send" {
  count = local.email_enabled ? 1 : 0

  input = {
    app_role        = "Mail.Send"
    principal_id    = local.automation_principal_id
    resource_app_id = "00000003-0000-0000-c000-000000000000"
  }
}

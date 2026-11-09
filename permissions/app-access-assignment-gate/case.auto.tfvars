tenant_id = "00000000-0000-0000-0000-000000000001"

# Nest sources: rosters are maintained only in the source; multiple Apps reference the same one, switching Apps means switching references
nest_sources = {
  "SGRP-BIZ-RELAY" = [
    "alice.one@example.com",
    "bob.one@example.com",
  ]
  "SGRP-BIZ-PULSE" = [
    "bob.one@example.com", # in both sources: deduplicated by distinct after expansion
    "carol.two@example.com",
    "dave.two@example.com", # deliberately left out of user_object_ids: takes the Graph lookup path
  ]
}

applications = {
  app_one = {
    display_name                 = "App One"
    app_role_assignment_required = true
    sso_group_name               = "SGRP-APP-ONE"
    nested_groups                = ["SGRP-BIZ-RELAY", "SGRP-BIZ-PULSE"]
    members                      = [] # exception belonging to no source
    group_membership_claims      = ["ApplicationGroup"]
  }

  app_two = {
    display_name                 = "App Two"
    app_role_assignment_required = true
    sso_group_name               = "SGRP-APP-TWO"
    nested_groups                = ["SGRP-BIZ-PULSE"]
    members                      = ["erin.two@example.com"] # exception for App Two only
  }
}

# Already-verified object_ids; remove a key or add an unlisted UPN and plan will show the uncached + Graph lookup shape.
user_object_ids = {
  "alice.one@example.com" = "11111111-1111-4111-8111-111111111111"
  "bob.one@example.com"   = "22222222-2222-4222-8222-222222222222"
  "carol.two@example.com" = "33333333-3333-4333-8333-333333333333"
  "erin.two@example.com"  = "99999999-9999-4999-8999-999999999999"
}

logic_app = {
  name           = "la-app-access-review"
  oauth_audience = "https://management.azure.com/"
  caller_apps = {
    app-one-backend = "44444444-4444-4444-8444-444444444444"
    app-two-backend = "55555555-5555-4555-8555-555555555555"
  }
  approval_required = true
  supports_batch    = true
  callback_enabled  = true

  apps = {
    app_one = {
      display_name  = "App One"
      approver_upns = ["owner.one@example.com"]
    }
    app_two = {
      display_name  = "App Two"
      approver_upns = ["owner.two@example.com"]
    }
  }

  groups = {
    SGRP-APP-ONE = {
      group_object_id = "66666666-6666-4666-8666-666666666666"
      allowed_apps    = ["app_one"]
    }
    SGRP-APP-TWO = {
      group_object_id = "77777777-7777-4777-8777-777777777777"
      allowed_apps    = ["app_two"]
    }
  }
}

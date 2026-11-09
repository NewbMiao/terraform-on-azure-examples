custom_rules = [
  {
    name            = "AllowPulsePath"
    action          = "Allow"
    operator        = "RegEx"
    regression_gate = "check"
    match_values    = ["^/demo/(chat|preview/[^/?]+|items/[^/?]+)(/)?(\\?.*)?$"]
    path_regression = {
      must_match = [
        "/demo/chat",
        "/demo/preview/slide-01",
        "/demo/preview/slide-01/",
        "/demo/preview/slide-01?rev=2",
        "/demo/items/widget-a",
      ]
      must_not_match = [
        "/demo/preview",
        "/demo/items/",
        "/demo/chat/extra",
        "/other/demo/chat",
      ]
    }
  },
  {
    name            = "AllowPulseHookPath"
    action          = "Allow"
    operator        = "RegEx"
    regression_gate = "test"
    match_values    = ["^/demo/hooks/[^/?]+(/)?(\\?.*)?$"]
    path_regression = {
      must_match = [
        "/demo/hooks/deploy",
        "/demo/hooks/deploy/",
        "/demo/hooks/deploy?token=1",
      ]
      must_not_match = [
        "/demo/hooks",
        "/demo/hooks/",
        "/demo/hook/deploy",
      ]
    }
  },
]

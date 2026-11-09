# regression_gate=test: asserts use local.*_failures, listing only the URI rows on failure instead of dumping all of custom_rules.

run "hook_path_regression_passes" {
  command = plan

  assert {
    condition     = length(local.path_regression_test_must_match_failures) == 0
    error_message = join("\n", local.path_regression_test_must_match_failures)
  }

  assert {
    condition     = length(local.path_regression_test_must_not_match_failures) == 0
    error_message = join("\n", local.path_regression_test_must_not_match_failures)
  }
}

run "hook_narrow_pattern_breaks_must_match" {
  command = plan

  variables {
    test_match_values_override = {
      AllowPulseHookPath = ["^/demo/hooks/deploy$"]
    }
  }

  assert {
    condition     = length(local.path_regression_test_must_match_failures) > 0
    error_message = "The narrowed pattern should push at least one must_match into the failure list."
  }
}

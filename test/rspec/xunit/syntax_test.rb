# frozen_string_literal: true

require "test_helper"

RSpec.case "xUnit Syntax" do
  $_rspec_xunit_before_state = [:initial]

  setup { $_rspec_xunit_before_state.clear }

  test "setup is an alias of before" do
    assert_empty? $_rspec_xunit_before_state
  end
end

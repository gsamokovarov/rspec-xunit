# frozen_string_literal: true

require 'rspec/core'
require 'rspec/expectations'

module RSpec
  module XUnit
    module Assertions
      def assert(value = ::RSpec::Expectations::ExpectationTarget::UndefinedValue, &block)
        ::RSpec::Expectations::ExpectationTarget.for(value, block)
      end
    end
  end
end

RSpec::Core::ExampleGroup.define_example_group_method :case
RSpec::Core::ExampleGroup.define_example_group_method :fcase, focus: true
RSpec::Core::ExampleGroup.define_example_group_method :xcase, skip: 'Temporarily skipped with xcase'

RSpec::Core::ExampleGroup.define_example_method :test
RSpec::Core::ExampleGroup.define_example_method :ftest, focus: true
RSpec::Core::ExampleGroup.define_example_method :xtest, skip: 'Temporarily skipped with xtest'

RSpec::Matchers.include RSpec::XUnit::Assertions

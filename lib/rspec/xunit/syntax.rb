# frozen_string_literal: true

RSpec::Core::ExampleGroup.define_example_group_method :case
RSpec::Core::ExampleGroup.define_example_group_method :fcase, focus: true
RSpec::Core::ExampleGroup.define_example_group_method :xcase, skip: 'Temporarily skipped with xcase'

RSpec::Core::ExampleGroup.define_example_method :test
RSpec::Core::ExampleGroup.define_example_method :ftest, focus: true
RSpec::Core::ExampleGroup.define_example_method :xtest, skip: 'Temporarily skipped with xtest'

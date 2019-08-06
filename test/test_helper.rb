# frozen_string_literal: true

$LOAD_PATH << File.expand_path("#{__dir__}/../lib")
require 'rspec/xunit'

RSpec.configure do |config|
  config.pattern = '**/*_test.rb'
end

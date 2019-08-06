# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/xunit/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-xunit'
  spec.version       = RSpec::XUnit::VERSION
  spec.authors       = ['Genadi Samokovarov']
  spec.email         = ['gsamokovarov@gmail.com']
  spec.summary       = 'XUnit syntax for RSpec'
  spec.description   = 'XUnit syntax for RSpec'
  spec.homepage      = 'https://github.com/gsamokovarov/rspec-xunit'
  spec.license       = 'MIT'

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rspec-core', '>= 3.0'
  spec.add_dependency 'rspec-expectations', '>= 3.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end

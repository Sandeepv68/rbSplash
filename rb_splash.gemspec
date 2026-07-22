# frozen_string_literal: true

require_relative 'lib/rb_splash/version'

Gem::Specification.new do |spec|
  spec.name = 'rb_splash'
  spec.version = RbSplash::VERSION
  spec.authors = ['sande']
  spec.summary = 'A Ruby wrapper for the Unsplash API'
  spec.description = 'A promise-based Ruby API wrapper for the Unsplash API, ported from wrapsplash (TypeScript).'
  spec.homepage = 'https://github.com/sande/rb_splash'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.files = Dir['lib/**/*', 'LICENSE', 'README.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'concurrent-ruby', '~> 1.2'
  spec.add_dependency 'faraday', '~> 2.7'
  spec.add_dependency 'faraday-net_http', '~> 3.0'

  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'webmock', '~> 3.18'
  spec.metadata['rubygems_mfa_required'] = 'true'
end

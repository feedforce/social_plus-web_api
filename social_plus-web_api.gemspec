# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'social_plus/web_api/version'

Gem::Specification.new do |spec|
  spec.name          = 'social_plus-web_api'
  spec.version       = SocialPlus::WebApi::VERSION
  spec.authors       = %(OZAWA Sakuro)
  spec.email         = %(sakuro@users.noreply.github.com)
  spec.summary       = %q{SocialPlus Web API client}
  spec.description   = %q{SocialPlus Web API client}
  spec.homepage      = ''
  spec.license       = 'Confidential'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %(lib)

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'webmock'

  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'rubocop'
  spec.add_dependency 'activesupport', '>= 3.0'
end

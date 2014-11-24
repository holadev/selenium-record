# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'selenium_record/version'

Gem::Specification.new do |spec|
  spec.name          = 'seleniumrecord'
  spec.version       = SeleniumRecord::VERSION
  spec.authors       = ['David Saenz Tagarro']
  spec.email         = ['david.saenz.tagarro@gmail.com']
  spec.summary       = <<-summary
Selenium Record is a DSL for easily writing acceptance tests.
summary
  spec.description   = <<-desc
Selenium Record is a wrapper over Selenium ruby bindings to let you easily
apply the well known page object pattern.
desc
  spec.homepage      = 'https://github.com/dsaenztagarro/selenium-record'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'cane'
end

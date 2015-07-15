# coding: utf-8

require './lib/canvas-api/version'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = 'canvas-api'
  s.version = Canvas::API::VERSION.dup
  s.summary = 'Getting data from Canvas by API'
  s.description = 'Getting data from Canvas by API'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Serhii Herasymov']
  s.email = ['sgeras@softserveinc.com']
  s.homepage = 'https://github.com/grsmv/canvas-api'

  s.files = `git ls-files`.split($\).delete_if { |file| file =~ /^\.\w/ }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_development_dependency 'rspec',     '3.2.0'
  s.add_development_dependency 'rubocop',   '0.29.1'
  s.add_development_dependency 'simplecov', '0.9.2'
  s.add_development_dependency 'fuubar',    '2.0.0'

  s.add_runtime_dependency 'httparty',    '0.13.5'
  s.add_runtime_dependency 'parallel',    '1.6.0'
  s.add_runtime_dependency 'addressable', '2.3.8'
  s.add_runtime_dependency 'vcr',         '2.9.3'
  s.add_runtime_dependency 'webmock',     '1.20.4'
end

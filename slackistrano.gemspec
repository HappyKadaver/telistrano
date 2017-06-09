# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'telistrano/version'

Gem::Specification.new do |gem|
  gem.name          = "telistrano"
  gem.version       = Telistrano::VERSION
  gem.authors       = ['Dominic Althaus']
  gem.email         = ['althaus.dominic@gmail.com']
  gem.description   = %q{Send notifications to Telegram about Capistrano deployments.}
  gem.summary       = %q{Send notifications to Telegram about Capistrano deployments.}
  gem.homepage      = ''
  gem.license       = 'MIT'

  gem.required_ruby_version = '>= 2.0.0'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'capistrano', '>= 3.8.1'
  gem.add_dependency 'telegram-bot-ruby'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'pry'

  # gem.post_install_message = %Q{
  # }
end

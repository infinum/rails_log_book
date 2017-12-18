lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'log_book/version'

Gem::Specification.new do |spec|
  spec.name          = 'rails_log_book'
  spec.version       = LogBook::VERSION
  spec.authors       = ['Stjepan Hadjic']
  spec.email         = ['stjepan.hadjic@infinum.co']

  spec.summary       = 'Write a short summary, because Rubygems requires one.'
  spec.description   = 'Write a longer description or delete this line.'
  spec.homepage      = 'https://github.com/infinum/rails_log_book'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'pry-byebug'

  spec.add_dependency 'request_store'
  spec.add_dependency 'activerecord', '>= 4.0', '< 5.1'
end

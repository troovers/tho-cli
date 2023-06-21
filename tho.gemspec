# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','tho','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'tho'
  s.version = Tho::VERSION
  s.author = 'Thomas Roovers'
  s.email = 'thomas@geekk.nl'
  s.homepage = 'https://thomasroovers.nl'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A simple developer assistant'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.extra_rdoc_files = ['README.rdoc','tho.rdoc']
  s.rdoc_options << '--title' << 'tho' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'tho'
  s.add_development_dependency('rake','~> 0.9.2')
  s.add_development_dependency('rdoc', '~> 4.3')
  s.add_development_dependency('minitest', '~> 5.14')
  s.add_runtime_dependency('gli','~> 2.21.0')
  s.add_runtime_dependency('jwt','~> 2.7.0')
  s.add_runtime_dependency('tty-prompt','~> 0.23.1')
  s.add_runtime_dependency('dotenv', '~> 2.8.1')
end

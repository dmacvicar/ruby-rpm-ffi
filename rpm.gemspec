# -*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'rpm/gem_version'

Gem::Specification.new do |s|
  s.name        = 'rpm'
  s.version     = RPM::GEM_VERSION
  s.authors     = ['Duncan Mac-Vicar P.']
  s.email       = ['dmacvicar@suse.de']
  s.homepage    = ''
  s.summary     = 'Ruby bindings for rpm (package manager)'
  s.description = 'Ruby bindings for rpm. Almost a drop-in replacement for ruby-rpm. Uses FFI.'

  s.rubyforge_project = 'rpm'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  # specify any dependencies here; for example:
  s.add_development_dependency 'rake'
  s.add_runtime_dependency 'ffi'
end

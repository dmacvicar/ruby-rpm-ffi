# -*- encoding: utf-8 -*-

require_relative 'lib/rpm/gem_version'

Gem::Specification.new do |s|
  s.name        = 'rpm2'
  s.version     = RPM::GEM_VERSION
  s.authors     = ['Duncan Mac-Vicar P.', 'ManageIQ Authors']
  s.email       = ['dmacvicar@suse.de']
  s.homepage    = 'https://github.com/ManageIQ/ruby-rpm-ffi2'
  s.licenses    = ['MIT']
  s.summary     = 'Ruby bindings for rpm (package manager)'
  s.description = 'Ruby bindings for rpm. Almost a drop-in replacement for ruby-rpm. Uses FFI.'

  s.metadata['allowed_push_host']     = 'https://rubygems.org'
  s.metadata['rubygems_mfa_required'] = 'true'
  s.metadata['homepage_uri']          = s.homepage
  s.metadata['source_code_uri']       = s.homepage
  s.metadata['changelog_uri']         = "#{s.homepage}/blob/master/CHANGELOG.md"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  # specify any dependencies here; for example:
  s.add_development_dependency 'rake'
  s.add_runtime_dependency 'ffi'
end

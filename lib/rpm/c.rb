require 'ffi'

module RPM
  module C
    extend ::FFI::Library

    begin
      ffi_lib ['rpm',
               'librpm.so.9',
               'librpm.so.8', # Tumbleweed
               'librpm.so.7', # fedora 23
               'librpm.so.3', 'librpm.so.2', 'librpm.so.1']
    rescue LoadError => e
      raise(
        "Can't find rpm libs on your system: #{e.message}"
      )
    end
  end
end

require 'rpm/c/rpmtypes'
require 'rpm/c/rpmcallback'
require 'rpm/c/rpmtag'
require 'rpm/c/rpmlib'

module RPM
  module C

    def self.rpm_version_code
      ver = ::RPM::C.RPMVERSION.split('.', 3)
      return (ver[0].to_i<<16) + (ver[1].to_i<<8) + (ver[2].to_i<<0)
    end

  end
end

require 'rpm/c/rpmlog'
require 'rpm/c/rpmmacro'
require 'rpm/c/rpmio'
require 'rpm/c/header'
require 'rpm/c/rpmprob'
require 'rpm/c/rpmps'
require 'rpm/c/rpmfi'
require 'rpm/c/rpmdb'
require 'rpm/c/rpmcallback'
require 'rpm/c/rpmcli'
require 'rpm/c/rpmts'
require 'rpm/c/rpmds'
require 'rpm/c/rpmtd'

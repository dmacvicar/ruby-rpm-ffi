require 'rubygems'
require 'ffi'

module RPM
  module FFI

    extend ::FFI::Library

    begin
      ffi_lib('rpm')
    rescue LoadError => e
      raise(
        "Can't find rpm libs on your system: #{e.message}"
      )
    end

  end
end

require 'rpm/ffi/rpmtag'
require 'rpm/ffi/rpmtypes'
require 'rpm/ffi/rpmlib'
require 'rpm/ffi/rpmlog'
require 'rpm/ffi/rpmmacro'
require 'rpm/ffi/header'
require 'rpm/ffi/rpmts'
require 'rpm/ffi/rpmds'
require 'rpm/ffi/rpmdb'

module RPM
  module FFI

    def self.rpm_version_code
      ver = RPMVERSION.split('.', 3)
      return (ver[0].to_i<<16) + (ver[1].to_i<<8) + (ver[2].to_i<<0)
    end

  end
end
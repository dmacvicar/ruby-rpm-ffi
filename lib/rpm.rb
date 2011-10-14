
require 'rpm/lib'
require 'rpm/header'
require 'rpm/transaction'

module RPM

  Tag = RPM::Lib::Tag

  # compatibility
  Tag.to_h.each do |k,v|
    const_set "TAG_#{k.to_s.upcase}", v.to_i
  end

  def self.transaction
    yield Transaction.new
  end

  def self.[](name)
    ptr = FFI::MemoryPointer.new(:pointer, 1024)
    ret = RPM::Lib.expandMacros(nil, nil, ptr, 1024)
    ptr.read_string
  end

end

RPM::Lib.rpmReadConfigFiles(nil, nil)
RPM::Lib.rpmInitMacros(nil, RPM::Lib.MACROFILES)
# TODO
# set verbosity



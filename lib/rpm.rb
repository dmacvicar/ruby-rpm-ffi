
require 'rpm/lib'
require 'rpm/header'
require 'rpm/transaction'

module RPM

  module LibC
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    # call #attach_function to attach to malloc, free, memcpy, bcopy, etc.
     attach_function :malloc, [:size_t], :pointer
  end


  Tag = RPM::Lib::Tag
  LogLevel = RPM::Lib::LogLevel
  
  def self.transaction
    yield Transaction.new
  end


  # @param [String] name Name of the macro
  # @return [String] value of macro +name+
  def self.[](name)
    val = String.new
    buffer = FFI::MemoryPointer.new(:pointer, 1024)
    buffer.write_string("%{#{name}}")
    ret = RPM::Lib.expandMacros(nil, nil, buffer, 1024)
    buffer.read_string
  end

end

RPM::Lib.rpmReadConfigFiles(nil, nil)
RPM::Lib.rpmInitMacros(nil, RPM::Lib.MACROFILES)

# TODO
# set verbosity


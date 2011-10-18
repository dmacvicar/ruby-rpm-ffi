
require 'rpm/ffi'
require 'rpm/header'
require 'rpm/transaction'
require 'rpm/version'
require 'rpm/dependency'
require 'rpm/utils'

module RPM

  module LibC
    extend ::FFI::Library
    ffi_lib ::FFI::Library::LIBC

    # call #attach_function to attach to malloc, free, memcpy, bcopy, etc.
     attach_function :malloc, [:size_t], :pointer
  end


  TAG = RPM::FFI::Tag
  LOG = RPM::FFI::Log
  SENSE = RPM::FFI::Sense
  
  def self.transaction
    yield Transaction.new
  end


  # @param [String] name Name of the macro
  # @return [String] value of macro +name+
  def self.[](name)
    val = String.new
    buffer = ::FFI::MemoryPointer.new(:pointer, 1024)
    buffer.write_string("%{#{name}}")
    ret = RPM::FFI.expandMacros(nil, nil, buffer, 1024)
    buffer.read_string
  end

  # Setup a macro
  # @param [String] name Name of the macro
  # @param [String] value Value of the macro or +nil+ to delete it
  def self.[]=(name, value)
    if value.nil?
      RPM::FFI.delMacro(nil, name.to_s)
    else
      RPM::FFI.addMacro(nil, name.to_s, nil, value.to_s, RPM::FFI::RMIL_DEFAULT)
    end
  end

end
 
RPM::FFI.rpmReadConfigFiles(nil, nil)
RPM::FFI.rpmInitMacros(nil, RPM::FFI.MACROFILES)

# TODO
# set verbosity

require 'rpm/compat'

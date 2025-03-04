
require 'rpm/c'
require 'rpm/package'
require 'rpm/file'
require 'rpm/db'
require 'rpm/problem'
require 'rpm/transaction'
require 'rpm/match_iterator'
require 'rpm/version'
require 'rpm/dependency'
require 'rpm/utils'

module RPM
  TAG = RPM::C::Tag
  LOG = RPM::C::Log
  SENSE = RPM::C::Sense
  FILE = RPM::C::FileAttrs
  FILE_STATE = RPM::C::FileState
  TRANS_FLAG = RPM::C::TransFlags
  PROB_FILTER = RPM::C::ProbFilter
  MIRE = RPM::C::RegexpMode

  # Creates a new transaction and pass it
  # to the given block
  #
  # @param [String] root dir, default '/'
  #
  # @example
  #   RPM.transaction do |ts|
  #      ...
  #   end
  #
  def self.transaction(root = '/')
    ts = Transaction.new
    ts.root_dir = root
    yield ts
  ensure
    ts.ptr.free
  end

  # @param [String] name Name of the macro
  # @return [String] value of macro +name+
  def self.[](name)
    if C::rpm_version_code >= ((4 << 16) + (14 << 8) + (0 << 0))
      obuf = ::FFI::MemoryPointer.new(:pointer, 1)
      sbuf = FFI::MemoryPointer.from_string("%{#{name}}")
      ret = RPM::C.rpmExpandMacros(nil, sbuf, obuf, 0)
      raise if ret < 0

      val = obuf.read_pointer
      val.nil? ? nil : val.read_string
    else
      buffer = ::FFI::MemoryPointer.new(:pointer, 1024)
      buffer.write_string("%{#{name}}")
      ret = RPM::C.expandMacros(nil, nil, buffer, 1024)
      raise if ret < 0

      buffer.read_string
    end
  end

  # Setup a macro
  # @param [String] name Name of the macro
  # @param [String] value Value of the macro or +nil+ to delete it
  def self.[]=(name, value)
    if value.nil?
      if C::rpm_version_code >= ((4 << 16) + (14 << 8) + (0 << 0))
        RPM::C.rpmPopMacro(nil, name.to_s)
      else
        RPM::C.delMacro(nil, name.to_s)
      end
    else
      if C::rpm_version_code >= ((4 << 16) + (14 << 8) + (0 << 0))
        RPM::C.rpmPushMacro(nil, name.to_s, '', value.to_s, RPM::C::RMIL_DEFAULT)
      else
        RPM::C.addMacro(nil, name.to_s, '', value.to_s, RPM::C::RMIL_DEFAULT)
      end
    end
  end
end

RPM::C.rpmReadConfigFiles(nil, nil)
RPM::C.rpmInitMacros(nil, RPM::C.MACROFILES)

# TODO
# set verbosity

require 'rpm/compat'

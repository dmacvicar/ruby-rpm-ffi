
module RPM
  module C
    attach_variable :MACROFILES, :macrofiles, :string
    # ...

    # Markers for sources of macros added throughout rpm.
    RMIL_DEFAULT = -15
    RMIL_MACROFILES = -13
    RMIL_RPMRC = -11
    RMIL_CMDLINE = -7
    RMIL_TARBALL = -5
    RMIL_SPEC = -3
    RMIL_OLDSPEC = -1
    RMIL_GLOBAL = 0

    # ...
    # http://rpm.org/wiki/Releases/4.14.0 deprecated addMacro/delMacro
    if rpm_version_code >= ((4 << 16) + (14 << 8) + (0 << 0))
      attach_function 'rpmPushMacro', [:pointer, :string, :string, :string, :int], :void
      attach_function 'rpmPopMacro', [:pointer, :string], :void
      attach_function 'rpmExpandMacros', [:pointer, :pointer, :pointer, :int], :int
    else
      attach_function 'addMacro', [:pointer, :string, :string, :string, :int], :void
      attach_function 'delMacro', [:pointer, :string], :void
      attach_function 'expandMacros', [:pointer, :pointer, :pointer, :size_t], :int
    end
    # ...
    # ...
    attach_function 'rpmInitMacros', %i[pointer string], :void
    # ...
  end
end

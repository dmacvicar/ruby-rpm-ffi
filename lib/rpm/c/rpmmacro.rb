
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
    attach_function 'addMacro', [:pointer, :string, :string, :string, :int], :void
    attach_function 'delMacro', [:pointer, :string], :void
    # ...
    attach_function 'expandMacros', [:pointer, :pointer, :pointer, :size_t], :int
    # ...
    attach_function 'rpmInitMacros', [:pointer, :string], :void
    # ...
  end
end

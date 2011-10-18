
module RPM

  module FFI

    attach_variable :MACROFILES, :macrofiles, :string
    # ...
    attach_function 'expandMacros', [:pointer, :pointer, :pointer, :size_t], :int
    # ...
    attach_function 'rpmInitMacros', [:pointer, :string], :void
    # ...

    # RPMIO
    attach_function 'Fstrerror', [:pointer], :string
    # ...
    attach_function 'Fclose', [:pointer], :int
    # ...
    attach_function 'Fopen', [:string, :string], :pointer
    # ...
    attach_function 'Ferror', [:pointer], :int
  end
  
end

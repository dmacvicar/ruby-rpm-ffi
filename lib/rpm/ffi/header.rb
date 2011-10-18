
module RPM

  module FFI

    attach_function 'headerNew', [], :pointer
    attach_function 'headerFree', [:pointer], :pointer
    attach_function 'headerLink', [:pointer], :pointer
    # ..
    HEADERGET_DEFAULT   = 0,        
    HEADERGET_MINMEM    = (1 << 0)
    HEADERGET_EXT       = (1 << 1)
    HEADERGET_RAW       = (1 << 2)
    HEADERGET_ALLOC     = (1 << 3)
    HEADERGET_ARGV      = (1 << 4)

    # ..
    attach_function 'headerGet', [:pointer, :tag_val, :pointer, :uint32], :int
    # ...
    attach_function 'headerNVR', [:pointer, :pointer, :pointer, :pointer], :int
    # ...
    attach_function 'headerGetAsString', [:pointer, Tag], :string
    # ...
    attach_function 'rpmReadPackageFile', [:pointer, :pointer, :string, :pointer], Rc

  end

end
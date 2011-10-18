module RPM

  module FFI

    attach_function 'rpmtdNew', [], :pointer
    attach_function 'rpmtdFree', [:pointer], :pointer
    attach_function 'rpmtdReset', [:pointer], :void
    attach_function 'rpmtdFreeData', [:pointer], :void
    attach_function 'rpmtdCount', [:pointer], :uint32
    attach_function 'rpmtdTag', [:pointer], :tag_val
    attach_function 'rpmtdType', [:pointer], TagType
    # ...
    attach_function 'rpmtdInit', [:pointer], :int
    attach_function 'rpmtdNext', [:pointer], :int
    # ...
    attach_function 'rpmtdGetString', [:pointer], :string

  end
end
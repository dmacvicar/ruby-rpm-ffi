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
    attach_function 'rpmtdNextUint32', [:pointer], :pointer
    attach_function 'rpmtdNextUint64', [:pointer], :pointer
    attach_function 'rpmtdNextString', [:pointer], :string
    attach_function 'rpmtdGetChar', [:pointer], :pointer
    attach_function 'rpmtdGetUint16', [:pointer], :pointer
    attach_function 'rpmtdGetUint32', [:pointer], :pointer
    attach_function 'rpmtdGetUint64', [:pointer], :pointer
    attach_function 'rpmtdGetString', [:pointer], :string
    attach_function 'rpmtdGetNumber', [:pointer], :uint64
    # ...
    attach_function 'rpmtdFromUint8', [:pointer, :tag_val, :pointer, :uint32], :int
    attach_function 'rpmtdFromUint16', [:pointer, :tag_val, :pointer, :uint32], :int
    attach_function 'rpmtdFromUint32', [:pointer, :tag_val, :pointer, :uint32], :int
    attach_function 'rpmtdFromUint64', [:pointer, :tag_val, :pointer, :uint32], :int
    attach_function 'rpmtdFromString', [:pointer, :tag_val, :string], :int
    attach_function 'rpmtdFromStringArray', [:pointer, :tag_val, :pointer, :uint32], :int
    # ...

  end
end
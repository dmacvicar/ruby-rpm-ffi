module RPM

  module FFI

    attach_function 'rpmtsCheck', [:pointer], :int
    attach_function 'rpmtsOrder', [:pointer], :int
    attach_function 'rpmtsRun', [:pointer, :pointer, :int], :int
    attach_function 'rpmtsLink', [:pointer], :pointer
    attach_function 'rpmtsCloseDB', [:pointer], :int
    attach_function 'rpmtsOpenDB', [:pointer, :int], :int
    attach_function 'rpmtsInitDB', [:pointer, :int], :int
    attach_function 'rpmtsGetDBMode', [:pointer], :int
    attach_function 'rpmtsSetDBMode', [:pointer, :int], :int
    attach_function 'rpmtsRebuildDB', [:pointer], :int
    attach_function 'rpmtsVerifyDB', [:pointer], :int
    attach_function 'rpmtsInitIterator', [:pointer, Tag, :pointer, :int], :pointer
  
    # more...
    attach_function 'rpmtsFree', [:pointer], :pointer
    #..
    attach_function 'rpmtsRootDir', [:pointer], :string
    attach_function 'rpmtsSetRootDir', [:pointer, :string], :int
    #...
    attach_function 'rpmtsCreate', [], :pointer

  end
end
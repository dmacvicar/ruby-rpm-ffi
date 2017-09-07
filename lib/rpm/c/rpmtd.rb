module RPM
  module C
    typedef :pointer, :rpmtd

    attach_function 'rpmtdNew', [], :pointer
    attach_function 'rpmtdFree', [:rpmtd], :pointer
    attach_function 'rpmtdReset', [:rpmtd], :void
    attach_function 'rpmtdFreeData', [:rpmtd], :void
    attach_function 'rpmtdCount', [:rpmtd], :uint32
    attach_function 'rpmtdTag', [:rpmtd], :rpmTagVal
    attach_function 'rpmtdType', [:rpmtd], TagType
    # ...
    attach_function 'rpmtdInit', [:rpmtd], :int
    attach_function 'rpmtdNext', [:rpmtd], :int
    # ...
    attach_function 'rpmtdNextUint32', [:rpmtd], :pointer
    attach_function 'rpmtdNextUint64', [:rpmtd], :pointer
    attach_function 'rpmtdNextString', [:rpmtd], :string
    attach_function 'rpmtdGetChar', [:rpmtd], :pointer
    attach_function 'rpmtdGetUint16', [:rpmtd], :pointer
    attach_function 'rpmtdGetUint32', [:rpmtd], :pointer
    attach_function 'rpmtdGetUint64', [:rpmtd], :pointer
    attach_function 'rpmtdGetString', [:rpmtd], :string
    attach_function 'rpmtdGetNumber', [:rpmtd], :uint64
    # ...
    attach_function 'rpmtdFromUint8', %i[rpmtd rpmTagVal pointer rpm_count_t], :int
    attach_function 'rpmtdFromUint16', %i[rpmtd rpmTagVal pointer rpm_count_t], :int
    attach_function 'rpmtdFromUint32', %i[rpmtd rpmTagVal pointer rpm_count_t], :int
    attach_function 'rpmtdFromUint64', %i[rpmtd rpmTagVal pointer rpm_count_t], :int
    attach_function 'rpmtdFromString', %i[rpmtd rpmTagVal string], :int
    attach_function 'rpmtdFromStringArray', %i[rpmtd rpmTagVal pointer rpm_count_t], :int
    # ...
  end
end

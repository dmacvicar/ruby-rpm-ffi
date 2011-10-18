module RPM

  module FFI
    attach_function 'rpmdbNextIterator', [:pointer], :pointer
    attach_function 'rpmdbFreeIterator', [:pointer], :pointer
  end
end
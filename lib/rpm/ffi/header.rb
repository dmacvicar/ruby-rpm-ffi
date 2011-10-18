
module RPM

  module FFI

    attach_function 'headerNew', [], :pointer
    attach_function 'headerFree', [:pointer], :pointer
    attach_function 'headerLink', [:pointer], :pointer
    # ..
    attach_function 'headerNVR', [:pointer, :pointer, :pointer, :pointer], :int
    # ...
    attach_function 'headerGetAsString', [:pointer, Tag], :string
    # ...
    attach_function 'rpmReadPackageFile', [:pointer, :pointer, :string, :pointer], Rc

  end

end
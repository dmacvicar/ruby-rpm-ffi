
module RPM

  module FFI
    
    attach_variable :RPMVERSION, :RPMVERSION, :string
    attach_variable :RPMEVR, :rpmEVR, :string

    attach_function 'rpmReadConfigFiles', [:string, :string], :int

    # ...
    attach_function 'rpmvercmp', [:string, :string], :int
        
  end
end
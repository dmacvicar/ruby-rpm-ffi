
module RPM
  module C
    attach_variable :RPMVERSION, :RPMVERSION, :string
    attach_variable :RPMEVR, :rpmEVR, :string

    attach_function 'rpmReadConfigFiles', %i[string string], :int

    # ...
    attach_function 'rpmvercmp', %i[string string], :int
  end
end


module RPM

  module FFI

  	Rc = enum(
      :ok, 0,
      :notfound, 1,
      :fail, 2,
      :nottrusted, 3,
      :nokey, 4
    )
    
  end
end
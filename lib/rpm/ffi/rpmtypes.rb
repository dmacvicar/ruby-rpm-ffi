
module RPM

  module FFI

  	Rc = enum(
      :ok, 0,
      :notfound, 1,
      :fail, 2,
      :nottrusted, 3,
      :nokey, 4
    )

    typedef :int32, :rpm_tag_t
    typedef :uint32, :rpm_tagtype_t;
    typedef :uint32, :rpm_count_t
    typedef :rpm_tag_t, :rpmTagVal;
    typedef :rpm_tag_t, :rpmDbiTagVal

    typedef :uint32, :rpmFlags

    typedef :pointer, :FD_t
    typedef :pointer, :fnpyKey

  end
end
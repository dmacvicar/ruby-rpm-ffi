
module RPM
  module C
    Rc = enum(
      :ok, 0,
      :notfound, 1,
      :fail, 2,
      :nottrusted, 3,
      :nokey, 4
    )

    typedef :int32, :rpm_tag_t
    typedef :uint32, :rpm_tagtype_t
    typedef :uint32, :rpm_count_t
    typedef :rpm_tag_t, :rpmTagVal
    typedef :rpm_tag_t, :rpmDbiTagVal

    typedef :uint32, :rpmFlags
    typedef :uint32, :rpm_off_t
    typedef :uint64, :rpm_loff_t

    typedef :pointer, :FD_t
    typedef :pointer, :fnpyKey
    typedef :pointer, :rpmCallbackData

    typedef :uint64, :rpm_loff_t
  end
end

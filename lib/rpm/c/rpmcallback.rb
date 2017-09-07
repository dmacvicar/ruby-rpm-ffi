
module RPM
  module C
    CallbackType = enum(:rpmCallbackType, [
                          :unknown, 0,
                          :inst_progress,   (1 << 0),
                          :inst_start,      (1 << 1),
                          :inst_open_file,  (1 << 2),
                          :inst_close_file, (1 << 3),
                          :trans_progress,  (1 << 4),
                          :trans_start,     (1 <<  5),
                          :trans_stop,      (1 <<  6),
                          :uninst_progress, (1 <<  7),
                          :uninst_start,    (1 <<  8),
                          :uninst_stop,        (1 << 9),
                          :repackage_progress, (1 << 10),
                          :repackage_start,    (1 << 11),
                          :repackage_stop,     (1 << 12),
                          :unpack_error,       (1 << 13),
                          :cpio_error,         (1 << 14),
                          :script_error,       (1 << 15)
                        ])

    typedef :pointer, :rpmCallbackData
    callback :rpmCallbackFunction, %i[pointer rpmCallbackType rpm_loff_t rpm_loff_t fnpyKey rpmCallbackData], :pointer
  end
end

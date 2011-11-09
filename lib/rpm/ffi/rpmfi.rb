
module RPM

  module FFI

    FileAttrs = enum(:file_attrs, 
      :none, 0,
      :config, (1 << 0),
      :doc, (1 << 1),
      :icon, (1 <<2),
      :missingok, (1 << 3),
      :noreplace, (1 << 4),
      :specfile, (1 << 5),
      :ghost, (1 << 6),
      :license, (1 << 7),
      :readme, (1 << 8),
      :exclude, (1 << 9),
      :unpatched, (1 << 10),
      :pubkey, (1 << 11)
    )

    FileState = enum(:file_state,
      :missing, -1,
      :normal, 0,
      :replaced, 1,
      :notinstalled, 2,
      :netshared, 3,
      :wrongcolor, 4
    )
  end
end

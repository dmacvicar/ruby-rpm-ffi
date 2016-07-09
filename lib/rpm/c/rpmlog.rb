
module RPM
  module C
    # rpmlog
    RPMLOG_PRIMASK = 0x07

    Log = enum(
      :emerg, 0,
      :alert, 1,
      :crit, 2,
      :err, 3,
      :warning, 4,
      :notice, 5,
      :info, 6,
      :debug, 7
    )

    attach_function 'rpmlogSetMask', [:int], :int
    # TODO: defines to set verbosity
    # ...
    attach_function 'rpmlogMessage', [], :string
  end
end

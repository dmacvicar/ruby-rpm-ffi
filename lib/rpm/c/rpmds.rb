
module RPM
  module C
    typedef :pointer, :rpmds

    Sense = enum(:rpmsenseFlags_e, [
                   :any, 0,
                   :less, (1 << 1),
                   :greater, (1 << 2),
                   :equal, (1 << 3),
                   # bit 4 unused
                   :posttrans, (1 << 5),
                   :prereq, (1 << 6),
                   #
                   :pretrans, (1 << 7),
                   :interp, (1 << 8),
                   :script_pre, (1 << 9),
                   :script_post, (1 << 10),
                   :script_preun, (1 << 11),
                   :script_postun, (1 << 12),
                   :script_verify, (1 << 13),
                   :find_requires, (1 << 14),
                   :find_provides, (1 << 15),
                   #
                   :triggerin, (1 << 16),
                   :triggerun, (1 << 17),
                   :triggerpostun, (1 << 18),
                   :missingok, (1 << 19),
                   # 20 23 unused
                   :rpmlib, (1 << 24),
                   :triggerprein, (1 << 25),
                   :keyring, (1 << 26),
                   :strong, (1 << 27),
                   :config, (1 << 28)
                 ])
    typedef :rpmFlags, :rpmsenseFlags

    # ...
    attach_function 'rpmdsSingle', %i[rpmTagVal string string rpmsenseFlags], :rpmds
    # ...
    attach_function 'rpmdsCompare', %i[rpmds rpmds], :int
  end
end

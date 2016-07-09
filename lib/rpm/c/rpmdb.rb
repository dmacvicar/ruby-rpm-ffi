module RPM
  module C
    typedef :pointer, :rpmdb
    typedef :pointer, :rpmdbMatchIterator

    RegexpMode = enum(:rpmMireMode, [
                        :default, :strcmp, :regex, :glob
                      ])

    attach_function 'rpmdbCountPackages', [:rpmdb, :string], :int
    attach_function 'rpmdbGetIteratorOffset', [:rpmdbMatchIterator], :uint
    attach_function 'rpmdbGetIteratorCount', [:rpmdbMatchIterator], :int
    attach_function 'rpmdbSetIteratorRE', [:rpmdbMatchIterator, :rpmTagVal, :rpmMireMode, :string], :int

    attach_function 'rpmdbInitIterator', [:rpmdb, :rpmDbiTagVal, :pointer, :size_t], :rpmdbMatchIterator

    attach_function 'rpmdbNextIterator', [:rpmdb], :header
    attach_function 'rpmdbFreeIterator', [:rpmdb], :rpmdbMatchIterator
  end
end

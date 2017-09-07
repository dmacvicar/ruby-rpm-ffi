module RPM
  module C
    typedef :pointer, :rpmdb
    typedef :pointer, :rpmdbMatchIterator

    RegexpMode = enum(:rpmMireMode, %i[
                        default strcmp regex glob
                      ])

    attach_function 'rpmdbCountPackages', %i[rpmdb string], :int
    attach_function 'rpmdbGetIteratorOffset', [:rpmdbMatchIterator], :uint
    attach_function 'rpmdbGetIteratorCount', [:rpmdbMatchIterator], :int
    attach_function 'rpmdbSetIteratorRE', %i[rpmdbMatchIterator rpmTagVal rpmMireMode string], :int

    attach_function 'rpmdbInitIterator', %i[rpmdb rpmDbiTagVal pointer size_t], :rpmdbMatchIterator

    attach_function 'rpmdbNextIterator', [:rpmdb], :header
    attach_function 'rpmdbFreeIterator', [:rpmdb], :rpmdbMatchIterator
  end
end

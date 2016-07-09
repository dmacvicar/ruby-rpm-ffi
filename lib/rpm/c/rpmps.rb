module RPM
  module C
    typedef :pointer, :rpmps
    typedef :pointer, :rpmpsi

    attach_function 'rpmpsInitIterator', [:rpmps], :rpmpsi
    attach_function 'rpmpsNextIterator', [:rpmpsi], :int
    attach_function 'rpmpsGetProblem', [:rpmpsi], :rpmProblem
    attach_function 'rpmpsFree', [:rpmps], :rpmps
  end
end

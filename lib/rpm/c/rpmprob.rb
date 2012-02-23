 
module RPM

  module C

    typedef :pointer, :rpmProblem

    ProbFilter = enum(:rpmprobFilterFlags_e, [
      :none, 0,
      :ignoreos, (1 << 0),
      :ignorearch, (1 << 1),
      :replacepkg, (1 << 2),
      :forcerelocate, (1 << 3),
      :replacenewfiles, (1 << 4),
      :replaceoldfiles, (1 << 5),
      :oldpackage, (1 << 6),
      :diskspace, (1 << 7),
      :disknodes, (1 << 8) ]
    )
        
    typedef :rpmFlags, :rpmprobFilterFlags

    ProblemType = enum(:rpmProblemType, [
      :badarch,
      :bados,
      :pkg_installed,
      :badrelocate,
      :requires,
      :conflict,
      :new_file_conflict,
      :file_conflict,
      :oldpackage,
      :diskspace,
      :disknodes,
      :obsoletes
    ])

    attach_function 'rpmProblemCreate', [:rpmProblemType, :string, :fnpyKey, :string, :string, :uint64], :rpmProblem
    attach_function 'rpmProblemFree', [:rpmProblem],  :rpmProblem
    attach_function 'rpmProblemLink', [:rpmProblem],  :rpmProblem
    attach_function 'rpmProblemCompare', [:rpmProblem, :rpmProblem], :int
    attach_function 'rpmProblemGetType', [:rpmProblem], :rpmProblemType
    attach_function 'rpmProblemGetKey', [:rpmProblem], :fnpyKey
    attach_function 'rpmProblemGetStr', [:rpmProblem], :string
    attach_function 'rpmProblemString', [:rpmProblem], :string
    end
end
module RPM
  module C
    typedef :pointer, :FD_t
    # RPMIO
    attach_function 'Fstrerror', [:FD_t], :string
    # ...
    attach_function 'Fclose', [:FD_t], :int
    # ...
    attach_function 'Fopen', %i[string string], :FD_t
    # ...
    attach_function 'Ferror', [:FD_t], :int

    attach_function 'fdDup', [:int], :FD_t

    attach_function 'Fstrerror', [:FD_t], :string

    attach_function 'fdLink', [:pointer], :FD_t
  end
end

module BigWig
  module FFI
    typedef :int, :curlcode
    typedef :void, :curl

    attach_function \
      :bwInit,
      [:size_t],
      :int

    attach_function \
      :bwCleanup,
      [],
      :void

    callback :callback_function, %i[pointer long uint8], :void

    attach_function \
      :bwIsBigWig,
      %i[string callback_function],
      :int

    attach_function \
      :bbIsBigBed,
      %i[string callback_function],
      :int

    attach_function \
      :bwOpen,
      %i[string callback_function string],
      :pointer

    attach_function \
      :bbOpen,
      %i[string callback_function],
      :pointer

    attach_function \
      :bbGetSQL,
      %i[pointer],
      :string

    attach_function \
      :bwClose,
      %i[pointer],
      :void
  end
end

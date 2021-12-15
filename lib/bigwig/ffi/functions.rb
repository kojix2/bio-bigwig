module BigWig
  module FFI
    attach_function \
      :bwInit,
      [:size_t],
      :int

    attach_function \
      :bwCleanup,
      [],
      :void
  end
end

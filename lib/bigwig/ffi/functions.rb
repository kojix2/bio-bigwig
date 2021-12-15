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

    # bwStats

    attach_function \
      :bwGetTid,
      %i[pointer string],
      :uint32_t

    attach_function \
      :bwDestroyOverlappingIntervals,
      [:pointer],
      :void

    attach_function \
      :bbDestroyOverlappingEntries,
      [:pointer],
      :void

    attach_function \
      :bwGetOverlappingIntervals,
      %i[pointer string uint32_t uint32_t],
      :pointer

    attach_function \
      :bbGetOverlappingEntries,
      %i[pointer string uint32_t uint32_t int],
      :pointer

    attach_function \
      :bwOverlappingIntervalsIterator,
      %i[pointer string uint32_t uint32_t uint32_t],
      :pointer

    attach_function \
      :bbOverlappingEntriesIterator,
      %i[pointer string uint32_t uint32_t int uint32_t],
      :pointer

    attach_function \
      :bwIteratorNext,
      %i[pointer],
      :pointer

    attach_function \
      :bwIteratorDestroy,
      %i[pointer],
      :void

    attach_function \
      :bwGetValues,
      %i[pointer string uint32_t uint32_t int],
      :pointer

    enum :bwStatsType, []

    attach_function \
      :bwStats,
      %i[pointer string uint32_t uint32_t uint32_t bwStatsType], # FIXME
      :pointer

    attach_function \
      :bwStatsFromFull,
      %i[pointer string uint32_t uint32_t uint32_t bwStatsType], # FIXME
      :pointer

    attach_function \
      :bwCreateHdr,
      %i[pointer int32_t],
      :int

    attach_function \
      :bwCreateChromList,
      %i[pointer pointer int64_t],
      :pointer

    attach_function \
      :bwWriteHdr,
      %i[pointer],
      :int

    attach_function \
      :bwAddIntervals,
      %i[pointer pointer pointer pointer pointer int32_t],
      :int

    attach_function \
      :bwAppendIntervals,
      %i[pointer pointer pointer pointer int32_t],
      :int

    attach_function \
      :bwAddIntervalSpans,
      %i[pointer string pointer uint32_t pointer uint32_t],
      :int

    attach_function \
      :bwAddIntervalSpanSteps,
      %i[pointer string uint32_t uint32_t uint32_t pointer uint32_t],
      :int

    attach_function \
      :bwAppendIntervalSpanSteps,
      %i[pointer pointer uint32_t],
      :int
  end
end

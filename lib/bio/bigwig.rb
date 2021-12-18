# frozen_string_literal: true

require_relative "bigwig/version"
require_relative "bigwig/bigwigext"

module Bio
  class BigWig
    class << self
      alias open new
    end

    def initialize(fname, rw = "r")
      initialize_raw(fname, rw)
      if block_given?
        begin
          yield self
        ensure
          close
        end
      end
    end

    BIGWIG_MAGIC      = 0x888FFC26
    BIGBED_MAGIC      = 0x8789F2EB
    CIRTREE_MAGIC     = 0x78ca8c91
    IDX_MAGIC         = 0x2468ace0
    DEFAULT_nCHILDREN = 64
    DEFAULT_BLOCKSIZE = 32_768
  end
end

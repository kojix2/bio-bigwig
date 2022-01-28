# frozen_string_literal: true

require_relative "bigwig/version"
require_relative "bigwig/bigwigext"

module Bio
  class BigWig
    def self.open(*args, **kwargs)
      file = new(*args, **kwargs)
      return file unless block_given?

      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def initialize(fname, rw = "r")
      raise "BigWig::new() does not take block; use BigWig::open() instead" if block_given?

      @fname = fname
      initialize_raw(fname, rw)
    end

    def path
      @fname
    end

    def stats(chrom, start, stop, nbins, type, exact)
      stats_raw(chrom, start, stop, nbins, type, exact)
    end

    def values(chrom, start = 0, stop = -1)
      values_raw(chrom, start, stop)
    end

    def intervals(chrom, start = 0, stop = -1)
      intervals_raw(chrom, start, stop)
    end

    BIGWIG_MAGIC      = 0x888FFC26
    BIGBED_MAGIC      = 0x8789F2EB
    CIRTREE_MAGIC     = 0x78ca8c91
    IDX_MAGIC         = 0x2468ace0
    DEFAULT_nCHILDREN = 64
    DEFAULT_BLOCKSIZE = 32_768
  end
end

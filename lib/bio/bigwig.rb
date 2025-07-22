# frozen_string_literal: true

require_relative "bigwig/version"
require_relative "bigwig/bigwigext"

module Bio
  # BigWig/BigBed file reader for Ruby
  #
  # @example Reading a local BigWig file
  #   Bio::BigWig.open("file.bw") do |bw|
  #     puts bw.header
  #     puts bw.chroms
  #   end
  #
  # @example Reading a remote BigWig file
  #   Bio::BigWig.open("https://example.com/file.bw") do |bw|
  #     values = bw.values("chr1", 0, 1000)
  #   end
  class BigWig
    # Open a BigWig/BigBed file
    #
    # @param args [Array] file path or URL
    # @param kwargs [Hash] options
    # @return [BigWig] file handle
    # @yield [BigWig] file handle for block usage
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

    # Initialize a BigWig/BigBed file handle
    #
    # @param fname [String] file path or URL
    # @param mode [String] file mode (default: "r")
    def initialize(fname, mode = "r")
      raise "BigWig::new() does not take block; use BigWig::open() instead" if block_given?

      @fname = fname
      initialize_raw(fname, mode)
    end

    # Get the file path
    #
    # @return [String] file path or URL
    def path
      @fname
    end

    # Get statistics for a genomic region
    #
    # @param chrom [String] chromosome name
    # @param start [Integer, nil] start position (0-based)
    # @param stop [Integer, nil] stop position (0-based)
    # @param nbins [Integer, nil] number of bins
    # @param type [String, Symbol, nil] statistic type ("mean", "max", "min", "sum", "coverage", "std")
    # @param exact [Boolean, nil] use exact calculation
    # @return [Array<Float>] statistics values
    def stats(chrom, start = nil, stop = nil, nbins: nil, type: nil, exact: nil)
      stats_raw(chrom, start, stop, nbins, type&.to_s, exact)
    end

    # Get values for a genomic region
    #
    # @param chrom [String] chromosome name
    # @param start [Integer] start position (0-based)
    # @param stop [Integer] stop position (0-based)
    # @return [Array<Float>] values
    def values(chrom, start, stop)
      values_raw(chrom, start, stop)
    end

    # Get intervals for a genomic region
    #
    # @param chrom [String] chromosome name
    # @param start [Integer] start position (0-based, default: 0)
    # @param stop [Integer] stop position (0-based, default: -1 for end of chromosome)
    # @return [Array<Array>] intervals as [start, end, value]
    def intervals(chrom, start = 0, stop = -1)
      intervals_raw(chrom, start, stop)
    end

    # Get entries for a genomic region (BigBed files only)
    #
    # @param chrom [String] chromosome name
    # @param start [Integer] start position (0-based, default: 0)
    # @param stop [Integer] stop position (0-based, default: -1 for end of chromosome)
    # @param with_string [Boolean] include string data (default: true)
    # @return [Array<Array>] entries as [start, end, string] or [start, end]
    def entries(chrom, start = 0, stop = -1, with_string: true)
      entries_raw(chrom, start, stop, with_string)
    end
  end
end

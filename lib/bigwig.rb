# frozen_string_literal: true

require "ffi"

require_relative "bigwig/version"

module BigWig
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end

  lib_name = ::FFI.map_library_name("libBigWig")
  self.ffi_lib = if ENV["LIBBIGWIGDIR"]
                   File.expand_path(lib_name, ENV["LIBBIGWIGDIR"])
                 else
                   File.expand_path("../vendor/#{lib_name}", __dir__)
                 end

  autoload :FFI, "bigwig/ffi"

  BIGWIG_MAGIC      = 0x888FFC26
  BIGBED_MAGIC      = 0x8789F2EB
  CIRTREE_MAGIC     = 0x78ca8c91
  IDX_MAGIC         = 0x2468ace0
  DEFAULT_nCHILDREN = 64
  DEFAULT_BLOCKSIZE = 32768
end

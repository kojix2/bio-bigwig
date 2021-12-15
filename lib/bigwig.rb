# frozen_string_literal: true

require "ffi"

require_relative "bigwig/version"

module BigWig
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end

  lib_name = ::FFI.map_library_name("libbigwig")
  self.ffi_lib = if ENV["LIBBIGWIGDIR"]
                   File.expand_path(lib_name, ENV["LIBBIGWIGDIR"])
                 else
                   File.expand_path("../vendor/#{lib_name}", __dir__)
                 end

  autoload :BigWig, "bigwig/ffi"
end

# frozen_string_literal: true

require_relative "lib/bigwig/version"

Gem::Specification.new do |spec|
  spec.name = "bigwig"
  spec.version = BigWig::VERSION
  spec.authors = ["kojix2"]
  spec.email = ["2xijok@gmail.com"]

  spec.summary = "bigwig"
  spec.description = "bigwig"
  spec.homepage = "https://github.com/kojix2/bw-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.files = Dir["*.{md,txt}", "{lib}/**/*", "vendor/libbigwig.{so,dylib}"]
  spec.require_paths = ["lib"]

  spec.add_dependency "ffi"
end

# frozen_string_literal: true

require_relative "lib/bio/bigwig/version"

Gem::Specification.new do |spec|
  spec.name          = "bigwig"
  spec.version       = Bio::BigWig::VERSION
  spec.authors       = ["kojix2"]
  spec.email         = ["2xijok@gmail.com"]

  spec.summary       = "bigwig"
  spec.description   = "bigwig"
  spec.homepage      = "https://github.com/kojix2/bw-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.files         = Dir["*.{md,txt}", "{lib,ext}/**/*", "vendor/libBigWig.{so,dylib}"]
  spec.require_paths = ["lib"]

  spec.extensions    = %w[ext/bio/bigwig/extconf.rb]

  spec.add_dependency "ffi"
end

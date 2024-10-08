# frozen_string_literal: true

require_relative "lib/bio/bigwig/version"

Gem::Specification.new do |spec|
  spec.name          = "bio-bigwig"
  spec.version       = Bio::BigWig::VERSION
  spec.authors       = ["kojix2"]
  spec.email         = ["2xijok@gmail.com"]

  spec.summary       = "A ruby library for accessing bigWig / bigBed files"
  spec.description   = "This is a Ruby binding for libBigWig (https://github.com/dpryan79/libBigWig), " \
                       "which provides high-speed access to bigWig or bigBed files."
  spec.homepage      = "https://github.com/kojix2/bio-bigwig"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.files         = Dir["*.{md,txt}",
                           "lib/**/*rb",
                           "ext/bio/bigwig/*.{rb,c,h}",
                           "ext/bio/bigwig/libBigWig/*.{c,h}",
                           "LICENSE.txt",
                           "ext/bio/bigwig/libBigWig/LICENSE" ]
  spec.require_paths = ["lib"]

  spec.extensions    = %w[ext/bio/bigwig/extconf.rb]
end

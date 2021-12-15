require_relative "ffi/constants"

module BigWig
  module FFI
    extend ::FFI::Library

    begin
      ffi_lib BigWig.ffi_lib
    rescue StandardError => e
      raise "Unable to load BigWig library: #{e}"
    end

    # Continue even if some functions are not found.
    def self.attach_function(*)
      super
    rescue ::FFI::NotFoundError => e
      warn e.message
    end
  end
end

require_relative "ffi/constants"
require_relative "ffi/functions"

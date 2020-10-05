module Ordway
  module Services
    class Error < Message
      VALIDATION_ERROR = 'VALIDATION_ERROR'.freeze

      def self.new_error(code, obj)
        new_message(code, obj)
      end

      def self.new_validation_error(obj)
        new_error(VALIDATION_ERROR, obj)
      end
    end
  end
end

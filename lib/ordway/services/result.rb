module Ordway
  module Services
    class Result
      attr_accessor :data, :errors, :warnings, :request_id

      WARNING = 'WARNING'.freeze

      def initialize(request_id)
        @data = {}
        @errors = []
        @warnings = []
        @request_id = request_id
      end

      def add_warning(message, code = WARNING)
        @warnings << Warning.new_warning(code, message)
      end

      def add_validation_error(message)
        @errors << Error.new_validation_error(message)
      end

      def status
        @errors.blank? ? :COMPLETED : :FAILED
      end

      # Add a validation error (if present) and raise an invalid exception
      def invalidate!(message = nil)
        add_validation_error(message) if message.present?
        raise InvalidException
      end
    end
  end
end

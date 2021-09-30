module Ordway
  module Services
    class Result
      attr_accessor :data, :errors, :warnings, :request_id, :status

      WARNING = 'WARNING'.freeze

      def initialize(request_id, status = :COMPLETED)
        @data = {}
        @errors = []
        @warnings = []
        @request_id = request_id
        @status = status
      end

      def add_warning(message, code = WARNING)
        @warnings << Warning.new_warning(code, message)
      end

      def add_validation_error(message)
        @errors << Error.new_validation_error(message)
      end

      # Add a validation error (if present) and raise an invalid exception
      def invalidate!(message = nil, status= :FAILED)

        @status = status if @status == :COMPLETED
 
        add_validation_error(message) if message.present?
        raise InvalidException(message)
      end
    end
  end
end

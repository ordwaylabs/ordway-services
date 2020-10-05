# Base class that handles all the service requests.
# All the services should be inherited from this class
module Ordway
  module Services
    class Processor
      attr_reader :request_id, :source, :params, :options

      include Ordway::Services::Logger

      delegate :invalidate!, to: :result

      def initialize(params, source, options = nil)
        @params = params
        @source = source
        @options = options
      end

      def self.call(*args, &block)
        new(*args, &block).call
      end

      def call
        generate_request_id
        log_start
        process
        post_processor_service
        result
      rescue InvalidException => e
        logger.error "InvalidException during service call #{request_id}: #{e}"
        result
      ensure
        log_completion
      end

      # All services should override process method
      # Raise error if not implemented
      def process
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      # Get the result object. Initialize if not present.
      def result
        @_result ||= Result.new(request_id)
      end

      private

      # Handles all the generic post processing events
      def post_processor_service
        logger.info "Post processing started for service #{request_id}"
        Ordway::Services::PostProcessor.call(self, called_service, params[:type], result)
        logger.info "Post processing completed for service #{request_id}"
      end

      def called_service
        @_called_service ||= self.class.name.demodulize.downcase
      end

      # Log the start of the service call
      def log_start
        @start_time = Time.now.utc
        logger.info "Service Starting - Request ID = #{request_id}"
      end

      # Log the completion of the service call
      def log_completion
        duration = Time.now.utc - @start_time
        logger.info "Service Completed - Request ID = #{request_id}, duration: #{duration} seconds,
                    status: #{result.status}, errors: #{result.errors}"
      end

      # Generate request ID to track the request lifecycle
      # UUID will be generated for each request
      def generate_request_id
        @request_id = SecureRandom.uuid
      end
    end
  end
end

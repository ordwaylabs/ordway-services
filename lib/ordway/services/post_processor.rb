# Service that handles all the post process events
module Ordway
  module Services
    class PostProcessor
      attr_reader :request_id, :operation, :entity, :caller_object, :result

      include Ordway::Services::Logger

      def initialize(caller_object, entity, operation, result)
        @entity = entity
        @operation = operation
        @request_id = caller_object.request_id
        @caller_object = caller_object
        @result = result
      end

      def self.call(*args, &block)
        new(*args, &block).call
      end

      def call
        perform_events(origin_events)
      rescue Errno::ENOENT => e
        logger.warn "Post processing meta data file not defined for the service with request ID: #{request_id}"
      end

      private

      # Perform the post process events
      def perform_events(events, pre_response = {})
        logger.info "Total events to be processed are: #{events}"
        events&.each do |event|
          logger.info "Starting Post processing event #{event}"
          response = execute(event, pre_response)
          logger.info "Post processing event response for event: #{event.keys.first.to_s.camelize}
                      request_id: #{request_id} - #{response}"
          # Find the next level of events to be executed based on the response status
          # statuses can be post_completed or post_failed
          next_level_events = event[event.keys.first]["post_#{response[:status]}".to_sym]

          logger.info "next level events : #{next_level_events}"
          unless next_level_events.empty?
            perform_events(next_level_events, response)
          end
        end
      end

      # Invoke the event
      def execute(event, pre_response)
        tries = 0
        event_options = build_options(event, pre_response)
        retry_limit = event_options[:retry_limit] || 1
        begin
          event_class = event.keys.first.to_s.camelize
          logger.info "Calling post processing event for service request_id: #{request_id}: #{event_class}"
          Object.const_get("::Services::PostEvents::#{event_class}")
                .send(:call, fetch_associated_object(pre_response), caller_object, event_options)
        rescue NameError => e
          logger.error "Name Error: #{e.message}"
          raise "Name Error: #{e.message}"
        rescue StandardError => e
          tries += 1
          logger.error "Post processing exception request_id: #{request_id} - #{e.message} : #{e.backtrace}"
          retry unless tries >= retry_limit
        end
      end

      # Use MetaDataConfigReader to parse the config file for all the post processing events to be performed
      def config
        @_config ||= Ordway::Services::MetaDataConfigReader.new("config/services/post_process/#{entity}.json").read
      end

      # The object on which the service acted upon
      def associated_object
        @_associated_object ||= result.data[:associated_object]
      end

      # Fetches the associated_object from the data from each events in case we wanted to change objects.
      # default will the main object the service is acted up on.
      def fetch_associated_object(pre_response)
        pre_response.dig(:data, :associated_object) || associated_object
      end

      # Find the first post completion event to be executed depending upon the result.status
      # For now we are considering only success and failure cases at the entry point of post process events
      # we may have more outcomes based on the processor response
      # This can be dealt with in the second phase of service framework implementation
      def origin_events
        action_based_config = config[operation.to_sym]
        unless action_based_config
          logger.warn 'No action base config defined in configuration json file'
          return []
        end


        action_based_config.first[result.status.to_sym]
      end

      def build_options(event, pre_response)
        event_params = event.values.first
        {
          methods: event_params[:methods],
          retry_limit: event_params[:retry_limit],
          async: event_params[:async],
          pre_status: pre_response.dig(:status),
          action: pre_response.dig(:data, :action),
          name: event.keys.first.to_s.camelize
        }
      end
    end
  end
end

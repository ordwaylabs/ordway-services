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
      end

      private

      # Perform the post process events
      def perform_events(events, pre_status = nil)
        events.each do |event|
          response = execute(event, pre_status)
          logger.info "Post processing event response for event: #{event.keys.first.to_s.camelize}
                      request_id: #{request_id} - #{response}"
          # Find the next level of events to be executed based on the response status
          # statuses can be post_completed or post_failed
          next_level_events = event[event.keys.first]["post_#{response[:status]}".to_sym]
          perform_events(next_level_events, response[:status]) unless next_level_events.empty?
        end
      end

      # Invoke the event
      def execute(event, pre_status)
        tries = 0
        event_options = build_options(event.values.first, pre_status)
        retry_limit = event_options[:retry_limit] || 1
        begin
          event_class = event.keys.first.to_s.camelize
          logger.info "Calling post processing event for service request_id: #{request_id}: #{event_class}"
          Object.const_get("::Services::PostEvents::#{event_class}")
                .send(:call, associated_object, caller_object, event_options)
        rescue NameError => ex
          logger.error "Name Error: #{ex.message}"
          raise "Name Error: #{ex.message}"
        rescue StandardError => ex
          tries += 1
          logger.error "Post processing exception request_id: #{request_id} - #{ex.message} : #{ex.backtrace}"
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

      # Find the first post completion event to be executed if result status is :COMPLETED
      # Find the first post failure event to be executed if the result status is :FAILED
      # For now we are considering only success and failure cases at the entry point of post process events
      # we may have more outcomes based on the processor response
      # This can be dealt with in the second phase of service framework implementation
      def origin_events
        action_based_config = config[operation.to_sym]
        if result.status == :COMPLETED
          action_based_config.first[:post_completed]
        else
          action_based_config.first[:post_failed]
        end
      end

      def build_options(event_params, pre_status)
        {
          methods: event_params[:methods],
          retry_limit: event_params[:retry_limit],
          async: event_params[:async],
          pre_status: pre_status
        }
      end
    end
  end
end

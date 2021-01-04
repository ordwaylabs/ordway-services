module Ordway
  module Services
    class Message
      attr_accessor :code, :message

      def initialize(args)
        args.each { |key, value| instance_variable_set("@#{key}", value) }
      end

      def self.new_message(code, obj)
        message =
          if obj.is_a?(Symbol)
            I18n.t(obj)
          else
            obj
          end

        new(code: code, message: message)
      end

      def to_hash
        { code: code, message: message }
      end
    end
  end
end

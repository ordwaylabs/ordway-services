module Ordway
  module Services
    class Warning < Message
      def self.new_warning(code, obj)
        new_message(code, obj)
      end
    end
  end
end

module Ordway
  module Services
    class InvalidException < StandardError
      def initialize(message)
        super(message)
      end
    end
  end
end

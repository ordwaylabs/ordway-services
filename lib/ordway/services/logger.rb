module Ordway
  module Services
    module Logger
      @@logger = nil

      def logger
        @@logger = Logging::Logger[self.class.name] if @@logger.nil?
        @@logger
      end
    end
  end
end

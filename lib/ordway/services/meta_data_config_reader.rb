# Responsible for parsing the metadata config JSON file
module Ordway
  module Services
    class MetaDataConfigReader
      def initialize(path)
        @path = path
      end

      def read
        JSON.parse(File.read(Rails.root.join(@path))).deep_symbolize_keys!
      end
    end
  end
end

require 'ordway/services/version'

module Ordway
  module Services
    autoload :Error, 'ordway/services/error'
    autoload :InvalidException, 'ordway/services/invalid_exception'
    autoload :Result, 'ordway/services/result'
    autoload :Message, 'ordway/services/message'
    autoload :MetaDataConfigReader, 'ordway/services/meta_data_config_reader'
    autoload :Logger, 'ordway/services/logger'
    autoload :Warning, 'ordway/services/warning'
    autoload :Processor, 'ordway/services/processor'
    autoload :PostProcessor, 'ordway/services/post_processor'
  end
end

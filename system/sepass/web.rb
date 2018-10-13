require 'dry/web/roda/application'
require 'dry/validation'

require_relative 'container'

module Sepass
  class Web < Dry::Web::Roda::Application
    SERIALIZABLE_CLASSES = [Array, Hash, Dry::Validation::Result, ROM::Struct].freeze
    SERIALIZATION_METHOD = ->(obj) { obj.to_h.to_json }
    JSON_ERROR_HANDLER   = lambda do |r|
      r.halt(400, error: 'not readable JSON')
    end

    configure do |config|
      config.container = Container
      config.routes = 'web/routes'.freeze
    end

    opts[:root] = Pathname(__FILE__).join('../..').realpath.dirname

    plugin :json, classes: SERIALIZABLE_CLASSES, serializer: SERIALIZATION_METHOD
    plugin :json_parser, error_handler: JSON_ERROR_HANDLER
    plugin :halt
    plugin :all_verbs
    plugin :multi_route
    plugin :error_handler
    plugin :path

    route do |r|
      r.multi_route
    end

    error do |e|
      self.class[:rack_monitor].instrument(:error, exception: e)

      if(ENV.fetch('RACK_ENV') == 'production')
        {errors: 'Something went wrong. Try again later...'}
      else
        raise e
      end
    end

    load_routes!
  end
end

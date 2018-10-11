require "dry/web/container"
require "dry/system/components"

module Sepass
  class Container < Dry::Web::Container
    configure do
      config.name = :sepass
      config.listeners = true
      config.default_namespace = "sepass"
      config.auto_register = %w[lib/sepass]
    end

    load_paths! "lib"
  end
end

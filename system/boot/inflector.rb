Sepass::Container.boot :inflector do
  init do
    require 'dry/inflector'
  end

  start do
    register :inflector, Dry::Inflector.new
  end
end

require 'bundler/setup'

begin
  require 'pry-byebug'
rescue LoadError
end

require_relative 'sepass/container'

Sepass::Container.finalize!

require 'sepass/web'

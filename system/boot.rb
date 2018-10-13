require 'bundler/setup'

begin
  require 'pry-byebug'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

require_relative 'sepass/container'

Sepass::Container.finalize!

require 'sepass/web'

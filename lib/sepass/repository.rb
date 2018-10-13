# auto_register: false

require 'rom-repository'
require 'sepass/container'
require 'sepass/import'

module Sepass
  class Repository < ROM::Repository::Root
    include Import.args['persistence.rom']
  end
end

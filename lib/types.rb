require 'sequel'
require 'dry-struct'
require 'dry-types'

module Types
  include Dry::Types.module

  EventTypes = Types::Strict::String.enum('create', 'fetch')
  EventStatuses = Types::Strict::String.enum('success', 'failure')
  SequelPgJson = Types.Constructor(Hash) { |hash| Sequel.pg_json(hash) }
end

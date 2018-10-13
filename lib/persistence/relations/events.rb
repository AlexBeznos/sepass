# frozen_string_literal: true

require 'types'

module Persistence
  module Relations
    class Events < ROM::Relation[:sql]
      schema(:events, infer: true) do
        attribute :id, Types::Strict::String

        attribute :data,       ::Types::SequelPgJson
        attribute :type,       ::Types::EventTypes
        attribute :status,     ::Types::EventStatuses
        attribute :secret_id,  Types::ForeignKey(:secrets)

        attribute :created_at, Types::Strict::DateTime

        associations do
          belongs_to :secret
        end
      end
    end
  end
end

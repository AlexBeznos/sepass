# frozen_string_literal: true

require 'types'

module Persistence
  module Relations
    class Secrets < ROM::Relation[:sql]
      schema(:secrets, infer: true) do
        attribute :id, Types::Strict::String

        attribute :secret,          Types::String
        attribute :expiration_date, Types::DateTime
        attribute :expired,         Types::Strict::Bool

        attribute :created_at, Types::Strict::DateTime

        associations do
          has_many :events
        end
      end
    end
  end
end

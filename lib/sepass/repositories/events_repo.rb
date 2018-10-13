require 'sepass/repository'

module Sepass
  module Repositories
    class EventsRepo < Sepass::Repository[:events]
      commands :create

      def history_by_secret(id)
        events
          .where(secret_id: id)
          .order(created_at: :desc)
      end
    end
  end
end

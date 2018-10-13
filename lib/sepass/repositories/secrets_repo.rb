require 'sepass/repository'

module Sepass
  module Repositories
    class SecretsRepo < Sepass::Repository[:secrets]
      commands :create, update: :by_pk

      def find_by_id(id)
        secrets.where(id: id).one
      end
    end
  end
end

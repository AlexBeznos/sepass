require 'dry/validation'

require 'sepass/transaction'
require 'sepass/import'

module Sepass
  module Transactions
    module Secrets
      class Create < Transaction
        include Import[
          'repositories.secrets_repo',
          'repositories.events_repo',
          'crypter'
        ]

        SCHEMA = Dry::Validation.Form do
          required(:ip).filled(:str?)
          required(:user_agent).maybe(:str?)
          required(:referrer).maybe(:str?)
          required(:params).schema do
            required(:secret) do
              str? | (array? & each { str? })
            end
            optional(:expired_at).filled(:time?)
          end
        end.freeze

        step :validate
        map :encrypt_secrets
        map :create_secret
        map :create_event

        def validate(input)
          validation = SCHEMA.(input)

          if validation.success?
            Success(validation.output)
          else
            Failure(errors: validation.errors[:params])
          end
        end

        def encrypt_secrets(params:, **rest)
          marshaled = Marshal.dump(params[:secret])
          rest.merge(secret: crypter.encrypt(marshaled), params: params)
        end

        def create_secret(secret:, params:, **rest)
          attrs = {
            expiration_date: params[:expired_at] || DateTime.now.next_day,
            secret:          secret
          }

          rest.merge(secret: secrets_repo.create(attrs), params: params)
        end

        def create_event(secret:, **rest)
          data = rest.slice(:ip, :user_agent, :referrer)

          events_repo.create(
            secret_id: secret.id,
            data:      data,
            type:      'create',
            status:    'success',
          )

          secret
        end
      end
    end
  end
end

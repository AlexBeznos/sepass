require 'dry/validation'

require 'sepass/transaction'
require 'sepass/import'

module Sepass
  module Transactions
    module Secrets
      class Fetch < Transaction
        include Import[
          'repositories.secrets_repo',
          'repositories.events_repo',
          'crypter'
        ]

        SCHEMA = Dry::Validation.Form do
          required(:id).filled(:str?)
          required(:ip).filled(:str?)
          required(:user_agent).maybe(:str?)
          required(:referrer).maybe(:str?)
        end.freeze

        step :validate
        step :find_secret
        map :prepare_secret_validity
        map :create_event
        step :check_secret_validity
        map :decode_secret
        map :expire_secret

        def validate(input)
          validation = SCHEMA.(input)

          if validation.success?
            Success(validation.output)
          else
            Failure(errors: validation.errors)
          end
        end

        def find_secret(id:, **rest)
          secret = secrets_repo.find_by_id(id)

          if secret
            Success(rest.merge(secret: secret))
          else
            Failure(errors: {secret: ['not found']})
          end
        end

        def prepare_secret_validity(secret:, **rest)
          valid = !(secret.expired || Time.now.to_i > secret.expiration_date.to_i)
          rest.merge(secret: secret, valid: valid)
        end

        def create_event(secret:, valid:, **rest)
          data = rest.slice(:ip, :user_agent, :referrer)

          events_repo.create(
            secret_id: secret.id,
            data:      data,
            type:      'fetch',
            status:    valid ? 'success' : 'failure'
          )

          rest.merge(secret: secret, valid: valid)
        end

        def check_secret_validity(valid:, **rest)
          if valid
            Success(rest)
          else
            Failure(errors: { secret: ['is expired'] })
          end
        end

        def decode_secret(secret:, **rest)
          decoded = crypter.decrypt(secret.secret)
          decoded = Marshal.load(decoded)

          rest.merge(
            secret:  secret,
            decoded: decoded
          )
        end

        def expire_secret(secret:, decoded:, **)
          secrets_repo
            .secrets
            .where(id: secret.id)
            .update(expired: true)

          decoded
        end
      end
    end
  end
end

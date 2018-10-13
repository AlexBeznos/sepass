module Sepass
  class Web
    path :secret do |secret|
      "/secrets/#{secret.id}"
    end

    route 'secrets' do |r| # rubocop:disable BlockLength
      r.is do
        r.post do
          r.resolve 'transactions.secrets.create' do |create|
            params = {
              params:     r.params,
              ip:         r.ip,
              user_agent: r.user_agent,
              referrer:   r.referrer
            }

            create.(params) do |a|
              a.success do |res|
                {
                  path: secret_path(res),
                  url:  [r.base_url, secret_path(res)].join
                }
              end
              a.failure { |errors| r.halt(422, errors) }
            end
          end
        end
      end

      r.is String do |id|
        r.get do
          r.resolve 'transactions.secrets.fetch' do |fetch|
            params = {
              id:         id,
              ip:         r.ip,
              user_agent: r.user_agent,
              referrer:   r.referrer
            }

            fetch.(params) do |a|
              a.success do |res|
                {secret: res}
              end
              a.failure { |errors| r.halt(422, errors) }
            end
          end
        end
      end
    end
  end
end

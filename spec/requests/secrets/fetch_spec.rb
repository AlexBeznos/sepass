require 'web_spec_helper'
require 'faker'
require 'securerandom'

require 'sepass/container'

RSpec.describe 'GET /secrets/:id', type: :request do
  before do
    header 'Content-Type', 'application/json'
  end

  context 'when valid' do
    let(:decoded) { Faker::Internet.password }
    let(:secret) do
      Factory[
        :secret,
        secret: Sepass::Container['crypter'].encrypt(Marshal.dump(decoded))
      ]
    end

    it 'returns decoded secret' do
      get "/secrets/#{secret.id}"

      expect(last_response.status).to eq(200)
      expect(last_response.parsed_body.keys).to match_array(%w[secret])
      expect(last_response.parsed_body['secret']).to eq(decoded)
    end
  end

  context 'when secret expired' do
    let(:decoded) { Faker::Internet.password }
    let(:secret) do
      Factory[
        :secret,
        secret: Sepass::Container['crypter'].encrypt(Marshal.dump(decoded)),
        expiration_date: DateTime.now.prev_day.to_time
      ]
    end

    it 'returns proper error' do
      get "/secrets/#{secret.id}"

      expect(last_response.status).to eq(422)
      expect(last_response.parsed_body.keys).to match_array(%w[errors])
      expect(last_response.parsed_body['errors'].keys).to match_array(%w[secret])
      expect(last_response.parsed_body.dig('errors', 'secret')).to eq(['is expired'])
    end
  end

  context 'when secret asked twice' do
    let(:decoded) { Faker::Internet.password }
    let(:secret) do
      Factory[
        :secret,
        secret: Sepass::Container['crypter'].encrypt(Marshal.dump(decoded))
      ]
    end

    it 'returns proper error' do
      get "/secrets/#{secret.id}"
      get "/secrets/#{secret.id}"

      expect(last_response.status).to eq(422)
      expect(last_response.parsed_body.keys).to match_array(%w[errors])
      expect(last_response.parsed_body['errors'].keys).to match_array(%w[secret])
      expect(last_response.parsed_body.dig('errors', 'secret')).to eq(['is expired'])
    end
  end

  context 'when secret not found' do
    it 'returns proper error' do
      get "/secrets/#{SecureRandom.uuid}"

      expect(last_response.status).to eq(422)
      expect(last_response.parsed_body.keys).to match_array(%w[errors])
      expect(last_response.parsed_body['errors'].keys).to match_array(%w[secret])
      expect(last_response.parsed_body.dig('errors', 'secret')).to eq(['not found'])
    end
  end
end

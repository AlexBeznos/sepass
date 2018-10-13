require 'web_spec_helper'
require 'faker'
require 'timecop'

require 'sepass/repositories/secrets_repo'

RSpec.describe 'POST /secrets', type: :request do
  before do
    header 'Content-Type', 'application/json'
    Timecop.freeze(Time.now)
  end

  after do
    Timecop.return
  end

  context 'when valid' do
    context 'with one password' do
      let(:last_secret) { Sepass::Repositories::SecretsRepo.new.secrets.one }
      let(:secret)      { Faker::Internet.password }
      let(:params) do
        { secret: secret }
      end

      it 'returns link to decoded password' do
        post '/secrets', params.to_json

        binding.pry
        expect(last_response.status).to eq(200)
        expect(last_response.parsed_body.keys).to match_array(%w[url path])
        expect(last_response.parsed_body['url']).to include(last_secret.id)
        expect(last_secret.expiration_date.to_i).to eq(DateTime.now.next_day.to_time.to_i)
        expect(last_secret.secret).not_to eq(secret)
      end
    end

    context 'with more than one password' do
      let(:last_secret) { Sepass::Repositories::SecretsRepo.new.secrets.one }
      let(:secret)      { 3.times.map(&Faker::Internet.method(:password)) }
      let(:params) do
        { secret: secret }
      end

      it 'returns link to decoded password' do
        post '/secrets', params.to_json

        expect(last_response.status).to eq(200)
        expect(last_response.parsed_body.keys).to match_array(%w[url path])
        expect(last_response.parsed_body['url']).to eq("http://example.org/secrets/#{last_secret.id}")
        expect(last_secret.expiration_date.to_i).to eq(DateTime.now.next_day.to_time.to_i)
        expect(last_secret.secret).not_to eq(secret)
      end
    end

    context 'with expiration date' do
      let(:last_secret) { Sepass::Repositories::SecretsRepo.new.secrets.one }
      let(:secret)      { Faker::Internet.method(:password) }
      let(:expiration)  { DateTime.now.next_year.next_day.to_time }
      let(:params) do
        {
          secret:     secret,
          expired_at: expiration
        }
      end

      it 'returns link to decoded password' do
        post '/secrets', params.to_json

        expect(last_response.status).to eq(200)
        expect(last_response.parsed_body.keys).to match_array(%w[url path])
        expect(last_response.parsed_body['url']).to eq("http://example.org/secrets/#{last_secret.id}")
        expect(last_secret.expiration_date.to_i).to eq(expiration.to_i)
        expect(last_secret.secret).not_to eq(secret)
      end
    end
  end

  context 'when invalid' do
    let(:expiration)  { DateTime.now.next_year.next_day.to_time }
    let(:params) do
      {
        expired_at: expiration
      }
    end

    it 'returns errors' do
      post '/secrets', params.to_json

      expect(last_response.status).to eq(422)
      expect(last_response.parsed_body.keys).to match_array(%w[errors])
      expect(last_response.parsed_body['errors'].keys).to match_array(%w[secret])
      expect(last_response.parsed_body.dig('errors', 'secret')).to eq(['is missing'])
    end
  end
end

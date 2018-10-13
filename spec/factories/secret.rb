require 'sepass/container'

Factory.define :secret do |f|
  f.secret { Sepass::Container['crypter'].encrypt(fake(:internet, :password)) }
  f.expiration_date { DateTime.now.next_day.to_time }
end

Factory.define secret_with_create_event: :secret do |f|
  f.association(:events, count: 1)
end

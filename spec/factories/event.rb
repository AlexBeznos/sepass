Factory.define :event do |f|
  f.type('create')
  f.status('success')
  f.data do
    {
      referrer:   fake(:internet, :url),
      user_agent: fake(:internet, :user_agent),
      ip:         fake(:internet, :public_ip_v4_address)
    }
  end
end
